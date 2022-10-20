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
      @web_service_host = ENV["PASSKIT_WEB_SERVICE_HOST"] || (raise "Please set PASSKIT_WEB_SERVICE_HOST")
      raise("PASSKIT_WEB_SERVICE_HOST must start with https://") unless @web_service_host.start_with?("https://")
      @certificate_key = ENV["PASSKIT_CERTIFICATE_KEY"] || (raise "Please set PASSKIT_CERTIFICATE_KEY")
      @private_p12_certificate = ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"] || (raise "Please set PASSKIT_PRIVATE_P12_CERTIFICATE")
      @apple_intermediate_certificate = ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"] || (raise "Please set PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE")
      @apple_team_identifier = ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"] || (raise "Please set PASSKIT_APPLE_TEAM_IDENTIFIER")
      @pass_type_identifier = ENV["PASSKIT_PASS_TYPE_IDENTIFIER"] || (raise "Please set PASSKIT_PASS_TYPE_IDENTIFIER")
    end
  end
end
