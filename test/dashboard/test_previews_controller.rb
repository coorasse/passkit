# frozen_string_literal: true

require "rails_helper"

class TestPreviewsController < ActionDispatch::IntegrationTest
  include Passkit::Engine.routes.url_helpers

  setup do
    @routes = Passkit::Engine.routes
  end

  def test_show_sends_the_preview_and_leaves_no_files_behind
    before = Dir.glob(Passkit::Generator::TMP_FOLDER.join("*"))

    get dashboard_preview_path("Passkit::ExampleStoreCard"),
      headers: {"Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin")}

    assert_response :success
    assert_equal "application/vnd.apple.pkpass", response.media_type
    assert_match(/filename="pass.pkpass"/, response.headers["Content-Disposition"])
    assert_equal 7, Zip::File.open_buffer(StringIO.new(response.body)).size
    assert_empty Dir.glob(Passkit::Generator::TMP_FOLDER.join("*")) - before
  end
end
