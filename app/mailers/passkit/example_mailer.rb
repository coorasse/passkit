module Passkit
  class ExampleMailer < ActionMailer::Base
    def example_email
      @passkit_url_generator = Passkit::UrlGenerator.new(Passkit::ExampleStoreCard, nil)
      mail(to: "passkit@example.com", subject: "Here is an example of a passkit email")
    end
  end
end
