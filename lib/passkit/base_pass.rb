module Passkit
  class BasePass
    def initialize(generator = nil)
      @generator = generator
    end

    def format_version
      ENV["PASSKIT_FORMAT_VERSION"] || 1
    end

    def apple_team_identifier
      ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"] || raise(Error.new("Missing environment variable: PASSKIT_APPLE_TEAM_IDENTIFIER"))
    end

    def pass_type_identifier
      ENV["PASSKIT_PASS_TYPE_IDENTIFIER"] || raise(Error.new("Missing environment variable: PASSKIT_PASS_TYPE_IDENTIFIER"))
    end

    def language
      nil
    end

    def last_update
      @generator&.updated_at
    end

    def pass_path
      rails_folder = Rails.root.join("private/passkit/#{folder_name}")
      # if folder exists, otherwise is in the gem itself under lib/passkit/base_pass
      if File.directory?(rails_folder)
        rails_folder
      else
        File.join(File.dirname(__FILE__), folder_name)
      end
    end

    def pass_type
      :storeCard
      # :coupon
    end

    def web_service_url
      raise Error.new("Missing environment variable: PASSKIT_WEB_SERVICE_HOST") unless ENV["PASSKIT_WEB_SERVICE_HOST"]
      "#{ENV["PASSKIT_WEB_SERVICE_HOST"]}/passkit/api"
    end

    def foreground_color
      "rgb(0, 0, 0)"
    end

    def background_color
      "rgb(255, 255, 255)"
    end

    def label_color
      "rgb(255, 255, 255)"
    end

    def organization_name
      "Passkit"
    end

    def description
      "A basic description for a pass"
    end

    # A pass can have up to ten relevant locations
    #
    # @see https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html
    def locations
      []
    end

    def voided
      false
    end

    def file_name
      @file_name ||= SecureRandom.uuid
    end

    # QRCode by default
    def barcode
      {messageEncoding: "iso-8859-1",
       format: "PKBarcodeFormatQR",
       message: "https://github.com/coorasse/passkit",
       altText: "https://github.com/coorasse/passkit"}
    end

    # Barcode example
    # def barcode
    #   { messageEncoding: 'iso-8859-1',
    #     format: 'PKBarcodeFormatCode128',
    #     message: '12345',
    #     altText: '12345' }
    # end

    def logo_text
      "Logo text"
    end

    def header_fields
      []
    end

    def primary_fields
      []
    end

    def secondary_fields
      []
    end

    def auxiliary_fields
      []
    end

    def back_fields
      []
    end

    private

    def folder_name
      self.class.name.demodulize.underscore
    end
  end
end
