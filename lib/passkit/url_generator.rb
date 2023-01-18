module Passkit
  class UrlGenerator
    include Passkit::Engine.routes.url_helpers

    def initialize(pass_class, generator = nil)
      @url = passes_api_url(host: Passkit.configuration.web_service_host,
        payload: PayloadGenerator.encrypted(pass_class, generator))
    end

    def ios
      @url
    end

    WALLET_PASS_PREFIX = "https://walletpass.io?u=".freeze
    # @see https://walletpasses.io/developer/
    def android
      "#{WALLET_PASS_PREFIX}#{@url}"
    end
  end
end
