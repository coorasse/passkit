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
      :certificate_key,
      :private_p12_certificate,
      :apple_intermediate_certificate,
      :apple_team_identifier,
      :pass_type_identifier

    DEFAULT_AUTHENTICATION = proc do
      authenticate_or_request_with_http_basic("Passkit Dashboard. Login required") do |username, password|
        username == ENV["PASSKIT_DASHBOARD_USERNAME"] && password == ENV["PASSKIT_DASHBOARD_PASSWORD"]
      end
    end
    def authenticate_dashboard_with(&block)
      @authenticate = block if block
      @authenticate || DEFAULT_AUTHENTICATION
    end

    def initialize
      @available_passes = {"Passkit::ExampleStoreCard" => -> {}}
      @web_service_host = ENV["PASSKIT_WEB_SERVICE_HOST"]
      @certificate_key = ENV["PASSKIT_CERTIFICATE_KEY"]
      @private_p12_certificate = ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"]
      @apple_intermediate_certificate = ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"]
      @apple_team_identifier = ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"]
      @pass_type_identifier = ENV["PASSKIT_PASS_TYPE_IDENTIFIER"]
    end

    def validate!
      raise "Please set PASSKIT_WEB_SERVICE_HOST" unless web_service_host
      raise("PASSKIT_WEB_SERVICE_HOST must start with https://") unless @web_service_host.start_with?("https://")
      raise "Please set PASSKIT_CERTIFICATE_KEY" unless certificate_key
      raise "Please set PASSKIT_PRIVATE_P12_CERTIFICATE" unless private_p12_certificate
      raise "Please set PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE" unless apple_intermediate_certificate
      raise "Please set PASSKIT_APPLE_TEAM_IDENTIFIER" unless apple_team_identifier
      raise "Please set PASSKIT_PASS_TYPE_IDENTIFIER" unless pass_type_identifier
    end
  end
end
