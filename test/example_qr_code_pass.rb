# frozen_string_literal: true

module Passkit
  class ExampleQrCodePass < BasePass
    def header_fields
      [{
        key: "value",
        label: "Value",
        value: 100,
        currencyCode: "CHF"
      }]
    end

    def back_fields
      [{
        key: "code",
        label: "Code",
        value: "https://github.com/coorasse/passkit"
      },
        {
          key: "website",
          label: "Website",
          value: "https://github.com/coorasse/passkit"
        }]
    end

    def auxiliary_fields
      [{
        key: "name",
        label: "full Name",
        value: "Alessandro Rodi"
      }]
    end
  end
end
