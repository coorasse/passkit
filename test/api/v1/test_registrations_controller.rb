# frozen_string_literal: true

require "rails_helper"
class TestRegistrationsController < ActionDispatch::IntegrationTest
  include Passkit::Engine.routes.url_helpers

  setup do
    @routes = Passkit::Engine.routes
  end

  def test_create
  end

  def test_show
  end

  def test_destroy
  end
end
