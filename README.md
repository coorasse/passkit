# <img src="./docs/wallet.png" alt="Goboony" height="50"/> Passkit

Your out-of-the-box solution to start serving Wallet Passes in your Ruby On Rails application.

Do you have a QRCode or a Barcode anywhere in your app that you want to distribute as Wallet Pass, compatible for iOS and Android? Look no further!

This gem provides everything necessary to distribute Wallet Passes in pkpass format, and gives you all the steps to follow for what we cannot provide.

**We provide:**

* A (not yet) fancy dashboard to manage your passes, registered devices and logs.
* All API endpoints to serve your passes: create, register, update, unregister, etc...
* All necessary ActiveRecord models.
* A BasePass model that you can extend to create your own passes.
* Some helpers to generate the necessary URLs, so that you can include them in the emails.
* Examples for everything.

**We don't provide (yet):**

* Full tests coverage: we are working on it!
* A fancy dashboard: our dashboard is really really simple right now. Pull requests are welcome!
* Push notifications: this is the most wanted feature I believe. Pull requests are welcome!
* Google Wallet integration: we use https://walletpasses.io/ on Android to read .pkpass format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'passkit'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install passkit

Run the initializer:

    $ rails g passkit:install

that will generate the migrations and the initializer file.

Mount the engine in your `config/routes.rb`:

```ruby
mount Passkit::Engine => '/passkit', as: 'passkit'
```

and run `bin/rails db:migrate`.

### Setup environment variables

If you followed the installation steps, you already saw that Passkit provides
you the tables and ActiveRecord models, and also an engine with the necessary APIs already implemented.

Now is your turn. Before proceeding, you need to set these ENV variables:
* `PASSKIT_WEB_SERVICE_HOST`
* `PASSKIT_CERTIFICATE_KEY`
* `PASSKIT_PRIVATE_P12_CERTIFICATE`
* `PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE`
* `PASSKIT_APPLE_TEAM_IDENTIFIER`
* `PASSKIT_PASS_TYPE_IDENTIFIER`

We have a [specific guide on how to get all these](docs/passkit_environment_variables.md), please follow it.
You cannot start using this library without these variables set, and we cannot do the work for you.

## Usage

If you followed the installation steps and you have the ENV variables set, we can start looking at what is provided for you.

### Dashboard

Head to `http://localhost:3000/passkit/dashboard/previews` and you will see a first `ExampleStoreCard` available for download.
You can click on the button and you will obtain a `.pkpass` file that you can simply open or install on your phone.
The dashboard has also a view for logs, and a view for emitted passes.

By default the dashboard is protected with basic auth. Set the credentials using these ENV variables:
* `PASSKIT_DASHBOARD_USERNAME`
* `PASSKIT_DASHBOARD_PASSWORD`

You can also change the authentication method used (see example below for Devise):

```ruby
# config/passkit.rb

Passkit.configure do |config|
  config.authenticate_dashboard_with do
    warden.authenticate! scope: :user
    ## redirect_to main_app.root_path unless warden.user.admin? # if you want to check a specific role
  end
end
```

### Mailer Helpers

If you use mailer previews, you can create the following file in `spec/mailers/previews/passkit/example_mailer_preview.rb`:

```ruby
module Passkit
  class ExampleMailerPreview < ActionMailer::Preview
    def example_email
      Passkit::ExampleMailer.example_email
    end
  end
end
```

and head to `http://localhost:3000/rails/mailers/` to see an example of email with links to download the Wallet Pass.
Please check the source code of [ExampleMailer](app/mailers/passkit/example_mailer.rb) to see how to distribute your own Wallet Passes.

### Example Passes

Please check the source code of the [ExampleStoreCard](lib/passkit/example_store_card.rb) to see how to create your own Wallet Passes.

Again, looking at these examples, is the easiest way to get started.

### Create your own Wallet Pass

You can create your own Wallet Passes by creating a new class that inherits from `Passkit::BasePass` and 
defining the methods that you want to override.

You can define colors, fields and texts. You can also define the logo and the background image.

You should place the images in a 'private/passkit/<your_downcased_passname>' folder.
There is a [dummy app in the gem](test/dummy) that you can use to check how to create your own Wallet Passes.

Full documentation for image specifications is on Apple's
[Pass Design and Creation](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html)
page. Naming the file according to convetion and putting it in 'private/passkit/<your_downcased_passname>' is all that's needed for it
to be included in the pass.

### Serve your Wallet Pass

Use the [Passkit::UrlGenerator](lib/passkit/url_generator.rb) to generate the URL to serve your Wallet Pass.
For one pass, you can initialize it with:

```ruby
Passkit::UrlGenerator.new(Passkit::MyPass, User.find(1))
```

For one passes, you can initialize it with:

```ruby
Passkit::UrlGenerator.new(Passkit::UserTicket, User.find(1), :tickets)
```
(this presumes you have `User.find(1).tickets` would return the ticket records)

and then use `.android` or `.ios` to get the URL to serve the Wallet Pass.
Again, check the example mailer included in the gem to see how to use it.

## Debug issues 

* On Mac, you can open the *.pkpass files with "Pass Viewer". Open the `Console.app` to log possible error messages and filter by "Pass Viewer" process.
* Check the logs on http://localhost:3000/passkit/dashboard/logs
* In case of error "The passTypeIdentifier or teamIdentifier provided may not match your certificate, 
or the certificate trust chain could not be verified." the certificate (p12) might be expired.


## Apple documentation

* [Apple Wallet Passes](https://developer.apple.com/documentation/walletpasses)
* [Send Push Notifications](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coorasse/passkit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/coorasse/passkit/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Passkit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/coorasse/passkit/blob/master/CODE_OF_CONDUCT.md).

## Credits

* <a href="https://www.flaticon.com/free-icons/credit-card" title="credit card icons">Credit card icons created by Iconfromus - Flaticon</a>

* https://www.sitepoint.com/whats-in-your-wallet-handling-ios-passbook-with-ruby/
