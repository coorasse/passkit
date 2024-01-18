module Passkit
  class ExampleStoreCard < BasePass
    def pass_type
      :storeCard
      # :coupon
    end

    def foreground_color
      "rgb(0, 0, 0)"
    end

    def background_color
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
    def barcodes
      [
        { messageEncoding: "iso-8859-1",
          format: "PKBarcodeFormatQR",
          message: "https://github.com/coorasse/passkit",
          altText: "https://github.com/coorasse/passkit" }
      ]
    end

    # Barcode example
    # def barcode
    #   { messageEncoding: 'iso-8859-1',
    #     format: 'PKBarcodeFormatCode128',
    #     message: '12345',
    #     altText: '12345' }
    # end

    def logo_text
      "Loyalty Card"
    end

    def app_launch_url
      "https://github.com/coorasse/passkit"
    end

    def relevant_date
      Time.current.strftime("%Y-%m-%dT%H:%M:%S%z")
    end

    def expiration_date
      # Expire the pass tomorrow
      (Time.current + 60*60*24).strftime("%Y-%m-%dT%H:%M:%S%z")
    end

    def semantics
      {
        balance: {
          amount: "100",
          currencyCode: "USD"
        }
      }
    end

    def header_fields
      [{
        key: "balance",
        label: "Balance",
        value: 100,
        currencyCode: "$"
      }]
    end

    def back_fields
      [{
        key: "example1",
        label: "Code",
        value: "0123456789"
      },
        {
          key: "example2",
          label: "Creator",
          value: "https://github.com/coorasse"
        },
        {
          key: "example3",
          label: "Contact",
          value: "rodi@hey.com"
        }]
    end

    def auxiliary_fields
      [{
        key: "name",
        label: "Name",
        value: "Alessandro Rodi"
      },
        {
          key: "email",
          label: "Email",
          value: "rodi@hey.com"
        },
        {
          key: "phone",
          label: "Phone",
          value: "+41 1234567890"
        }]
    end

  private

    def folder_name
      self.class.name.demodulize.underscore
    end
  end
end
