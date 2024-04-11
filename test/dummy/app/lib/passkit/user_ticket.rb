module Passkit
  class UserTicket < BasePass
    def pass_type
      :eventTicket
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
      [
        { latitude: 41.2273414693647, longitude: -95.92925748878405 }, # North Entrance
        { latitude: 41.22476226066285, longitude: -95.92879374051269 } # Main Entrance
      ]
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

    def expiration_date
      # Expire the pass tomorrow
      (Time.current + 60*60*24).strftime('%Y-%m-%dT%H:%M:%S%:z')
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
        value: @generator.name
      },
        {
          key: "email",
          label: "Email",
          value: "#{@generator.name}@hey.com"
        }]
    end

  private

    def folder_name
      'user_store_card'
    end
  end
end
