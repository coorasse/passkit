Passkit.configure do |config|
  config.available_passes['Passkit::UserStoreCard'] = -> { User.create!(name: "ExampleName") }
end
