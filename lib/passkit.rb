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
    configuration.verify!
  end

  def self.configured?
    self.configuration&.configured?
  end

  class Configuration
    attr_accessor :available_passes,
      :web_service_host,
      :certificate_key,
      :private_p12_certificate,
      :apple_intermediate_certificate,
      :apple_team_identifier,
      :pass_type_identifier,
      :dashboard_username,
      :dashboard_password,
      :format_version,
      :skip_verification

    REQUIRED_ATTRIBUTES = %i[
      web_service_host
      certificate_key
      private_p12_certificate
      apple_intermediate_certificate
      apple_team_identifier
      pass_type_identifier
    ]

    DEFAULT_AUTHENTICATION = proc do
      authenticate_or_request_with_http_basic("Passkit Dashboard. Login required") do |username, password|
        username == Passkit.configuration.dashboard_username && password == Passkit.configuration.dashboard_password
      end
    end
    def authenticate_dashboard_with(&block)
      @authenticate = block if block
      @authenticate || DEFAULT_AUTHENTICATION
    end

    def initialize
      # Required
      @certificate_key = ENV["PASSKIT_CERTIFICATE_KEY"]
      @private_p12_certificate = ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"]
      @apple_intermediate_certificate = ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"]
      @apple_team_identifier = ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"]
      @pass_type_identifier = ENV["PASSKIT_PASS_TYPE_IDENTIFIER"]

      # Optional
      @skip_verification = false
      @web_service_host = ENV["PASSKIT_WEB_SERVICE_HOST"] || "https://localhost:3000"
      @available_passes = { "Passkit::ExampleStoreCard" => -> {} }
      @format_version = ENV["PASSKIT_FORMAT_VERSION"] || 1
      @dashboard_username = ENV["PASSKIT_DASHBOARD_USERNAME"]
      @dashboard_password = ENV["PASSKIT_DASHBOARD_PASSWORD"]
    end

    def configured?
      REQUIRED_ATTRIBUTES.all? { |attr| send(attr).present? }
    end

    def verify!
      return if skip_verification

      REQUIRED_ATTRIBUTES.each do |attr|
        raise Error, "Please set #{attr.upcase}" unless send(attr).present?
      end

      raise Error, "PASSKIT_WEB_SERVICE_HOST must start with https://" unless web_service_host.start_with?("https://")
    end
  end
end
