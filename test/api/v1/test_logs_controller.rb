# frozen_string_literal: true

require "rails_helper"
class TestLogsController < ActionDispatch::IntegrationTest
  include Passkit::Engine.routes.url_helpers

  setup do
    @routes = Passkit::Engine.routes
  end

  def test_show
    post log_url, params: {"logs" => ["message 1", "message 2", "message 3"]}
    assert_equal 3, Passkit::Log.count
    assert_response :success
    assert_equal "{}", response.body
  end
end
