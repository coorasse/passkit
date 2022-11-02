# frozen_string_literal: true

require "rails_helper"

class TestRegistrationsController < ActionDispatch::IntegrationTest
  include Passkit::Engine.routes.url_helpers

  setup do
    @routes = Passkit::Engine.routes
  end

  def test_create
    Passkit::Factory.create_pass(Passkit::ExampleStoreCard)
    Passkit::Factory.create_pass(Passkit::ExampleStoreCard)
    pass1 = Passkit::Pass.first
    pass2 = Passkit::Pass.last

    assert_equal 2, Passkit::Pass.count

    register_pass(pass1)
    assert_equal 1, pass1.devices.count

    register_pass(pass2)
    assert_equal 1, pass2.devices.count
  end

  def test_show
  end

  def test_destroy
  end

  private

  def register_pass(pass)
    post device_register_path(device_id: 1, pass_type_id: pass.pass_type_identifier, serial_number: pass.serial_number),
      params: {pushToken: "1234567890"}.to_json,
      headers: {"Authorization" => "ApplePass #{pass.authentication_token}"}
  end
end
