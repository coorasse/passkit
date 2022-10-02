# frozen_string_literal: true

require_relative "lib/passkit/version"

Gem::Specification.new do |spec|
  spec.name = "passkit"
  spec.version = Passkit::VERSION
  spec.authors = ["Alessandro Rodi"]
  spec.email = ["coorasse@gmail.com"]

  spec.summary = "Serve Wallet Passes for iOS and Android directly from your Rails app"
  spec.description = "Passkit offers you a full Rails engine to serve Wallet Passes for iOS and Android in pkpass format."
  spec.homepage = "https://github.com/coorasse/passkit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/coorasse/passkit"
  spec.metadata["changelog_uri"] = "https://github.com/coorasse/passkit/blob/master/CHANGELOG.md"
  spec.metadata["funding_uri"] = "https://github.com/sponsors/coorasse"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "rails", ">= 5"
  spec.add_dependency "rubyzip", "~> 2.0"
  spec.add_development_dependency "sqlite3", "~> 1.4"
  spec.add_development_dependency "sprockets-rails", "~> 3.0"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "standard", "~> 1.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
