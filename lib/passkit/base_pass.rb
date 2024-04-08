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
      # :eventTicket
      # :generic
      # :boardingPass
    end

    def web_service_url
      raise Error.new("Missing environment variable: PASSKIT_WEB_SERVICE_HOST") unless ENV["PASSKIT_WEB_SERVICE_HOST"]
      "#{ENV["PASSKIT_WEB_SERVICE_HOST"]}/passkit/api"
    end

    # The foreground color, used for the values of fields shown on the front of the pass.
    def foreground_color
      "rgb(0, 0, 0)"
    end

    # The background color, used for the background of the front and back of the pass.
    # If you provide a background image, any background color is ignored.
    def background_color
      "rgb(255, 255, 255)"
    end

    # The label color, used for the labels of fields shown on the front of the pass.
    def label_color
      "rgb(255, 255, 255)"
    end

    # The organization name is displayed on the lock screen when your pass is relevant and by apps such as Mail which
    # act as a conduit for passes. The value for the organizationName key in the pass specifies the organization name.
    # Choose a name that users recognize and associate with your organization or company.
    def organization_name
      "Passkit"
    end

    # The description lets VoiceOver make your pass accessible to blind and low-vision users. The value for the
    # description key in the pass specifies the description.
    # @see https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html
    def description
      "A basic description for a pass"
    end

    # An array of up to 10 latitudes and longitudes.  iOS uses these locations to determine when to display the pass on the lock screen
    #
    # @see https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html
    def locations
      []
    end

    def voided
      false
    end

    # After base files are copied this is called to allow for adding custom images
    def add_other_files(path)
    end

    # Distance in meters from locations; if blank uses pass default
    def max_distance
    end

    # URL to launch the associated app (nil by default)
    # Returns a String
    def app_launch_url
    end

    # A list of Apple App Store identifiers for apps associated
    # with the pass. The first one that is compatible with the
    # device is picked.
    # Returns an array of numbers
    def associated_store_identifiers
      []
    end

    # An array of barcodes, the first one that can
    # be displayed on the device is picked.
    # Returns an array of hashes representing Pass.Barcodes
    def barcodes
      []
    end

    # List of iBeacon identifiers to identify when the
    # pass should be displayed.
    # Returns an array of hashes representing Pass.Beacons
    def beacons
      []
    end

    # Information specific to a boarding pass
    # Returns a hash representing Pass.BoardingPass
    def boarding_pass
    end

    # Information specific to a coupon
    # Returns a hash representing Pass.Coupon
    def coupon
    end

    # Information specific to an event ticket
    # Returns a hash representing Pass.EventTicket
    def event_ticket
    end

    # Date and time the pass expires, must include
    # days, hours and minutes (seconds are optional)
    # Returns a String representing the date and time in W3C format ("%Y-%m-%dT%H:%M:%S%z")
    def expiration_date
    end

    # Information specific to a generic pass
    # Returns a hash representing Pass.Generic
    def generic
    end

    # A key to identify group multiple passes together
    # (e.g. a number of boarding passes for the same trip)
    # Returns a String
    def grouping_identifier
    end

    # Information specific to Value Added Service Protocol
    # transactions
    # Returns a hash representing Pass.NFC
    def nfc
    end

    # Date and time when the pass becomes relevant and should be
    # displayed, must include days, hours and minutes
    # (seconds are optional)
    # Returns a String representing the date and time in W3C format ("%Y-%m-%dT%H:%M:%S%z")
    def relevant_date
    end

    # Machine readable metadata that the device can use
    # to suggest actions
    # Returns a hash representing SemanticTags
    def semantics
    end

    # Information specific to a store card
    # Returns a hash representing Pass.StoreCard
    def store_card
    end

    # Display the strip image without a shine effect
    # Returns a boolean
    def suppress_strip_shine
      true
    end

    # JSON dictionary to display custom information for
    # companion apps. Data isn't displayed to the user. e.g.
    # a machine readable version of the user's favourite coffee
    def user_info
    end

    def file_name
      @file_name ||= SecureRandom.uuid
    end

    # QRCode by default
    def barcode
      { messageEncoding: "iso-8859-1",
        format: "PKBarcodeFormatQR",
        message: "https://github.com/coorasse/passkit",
        altText: "https://github.com/coorasse/passkit" }
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

    def sharing_prohibited
      false
    end

  private

    def folder_name
      self.class.name.demodulize.underscore
    end
  end
end
