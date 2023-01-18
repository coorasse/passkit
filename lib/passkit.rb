# frozen_string_literal: true

require "rails"
require "passkit/engine"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.setup

module Passkit
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
    configuration.validate!
  end

  class Configuration
    attr_accessor :available_passes,
      :web_service_host,
      :p12_password,
      :p12_certificate,
      :p12_key,
      :wwdc_cert,
      :apple_team_identifier,
      :pass_type_identifier,
      :format_version,
      :dashboard_username,
      :dashboard_password

    def authenticate_dashboard_with(&block)
      @authenticate = block if block
      @authenticate || proc do
        authenticate_or_request_with_http_basic("Passkit Dashboard. Login required") do |username, password|
          username == dashboard_username && password == dashboard_password
        end
      end
    end

    def initialize
      @available_passes = {"Passkit::ExampleStoreCard" => -> {}}
      @web_service_host = ENV["PASSKIT_WEB_SERVICE_HOST"]
      @p12_password = ENV["PASSKIT_P12_PASSWORD"] || ENV["PASSKIT_CERTIFICATE_KEY"]
      @p12_certificate = ENV["PASSKIT_P12_CERTIFICATE"] || ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"]
      @p12_key = ENV["PASSKIT_P12_KEY"]      
      @wwdc_cert = ENV["PASSKIT_WWDC_CERT"] || ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"]
      @apple_team_identifier = ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"]
      @pass_type_identifier = ENV["PASSKIT_PASS_TYPE_IDENTIFIER"]
      @format_version = ENV["PASSKIT_FORMAT_VERSION"] || 1
    end

    def validate!
      raise "Please set PASSKIT_WEB_SERVICE_HOST" unless web_service_host
      raise("PASSKIT_WEB_SERVICE_HOST must start with https://") unless web_service_host.start_with?("https://")

      if wwdc_cert
        intermediate_certificate = OpenSSL::X509::Certificate.new(File.read(Rails.root_join(wwdc_cert)))
      else
        raise "Please set PASSKIT_WWDC_CERT"
      end

      raise "Please set PASSKIT_P12_CERTIFICATE" unless p12_certificate
      raise "Please set PASSKIT_P12_PASSWORD" unless p12_password

      if p12_key
        key = OpenSSL::PKey::RSA.new(p12_key, p12_password)
        cert = OpenSSL::X509::Certificate.new(p12_certificate)
      else
        p12_certificate = OpenSSL::PKCS12.new(File.read(Rails.root.join(Passkit.configuration.p12_certificate)), Passkit.configuration.p12_password)
        key = p12_certificate.key
        cert = p12_certificate.certificate
      end

      flag = OpenSSL::PKCS7::DETACHED | OpenSSL::PKCS7::BINARY
      OpenSSL::PKCS7.sign(cert, key, 'test', [intermediate_certificate], flag) # If this runs, all good

      raise "Please set PASSKIT_APPLE_TEAM_IDENTIFIER" unless apple_team_identifier
      raise "Please set PASSKIT_PASS_TYPE_IDENTIFIER" unless pass_type_identifier
    end
  end
end
