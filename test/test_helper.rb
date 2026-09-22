# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dotenv"
Dotenv.load(File.expand_path("../.env", __dir__), File.expand_path("../.env.test", __dir__))
require "passkit"

require "minitest/autorun"
