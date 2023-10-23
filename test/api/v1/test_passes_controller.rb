# frozen_string_literal: true

require "rails_helper"

class TestPassesController < ActionDispatch::IntegrationTest
  include Passkit::Engine.routes.url_helpers

  setup do
    @routes = Passkit::Engine.routes
  end

  def test_create
    payload = Passkit::PayloadGenerator.encrypted(Passkit::ExampleStoreCard)
    get passes_api_path(payload)
    assert_equal 1, Passkit::Pass.count
    assert_response :success
    zip_file = Zip::File.open_buffer(StringIO.new(response.body))
    assert_equal 7, zip_file.size
  end

  def test_show
    _pkpass = Passkit::Factory.create_pass(Passkit::ExampleStoreCard)
    assert_equal 1, Passkit::Pass.count
    pass = Passkit::Pass.last
    get pass_path(pass_type_id: ENV["PASSKIT_PASS_TYPE_IDENTIFIER"], serial_number: pass.serial_number)
    assert_response :unauthorized

    get pass_path(pass_type_id: ENV["PASSKIT_PASS_TYPE_IDENTIFIER"], serial_number: pass.serial_number),
      headers: {"Authorization" => "ApplePass #{pass.authentication_token}"}

    assert_response :success

    get pass_path(pass_type_id: ENV["PASSKIT_PASS_TYPE_IDENTIFIER"], serial_number: pass.serial_number),
      headers: {"Authorization" => "ApplePass #{pass.authentication_token}", "If-Modified-Since" => Time.zone.now.httpdate}

    assert_equal "", response.body
    assert_equal pass.last_update.httpdate, response.headers["Last-Modified"]
    assert_response :not_modified
  end
end
