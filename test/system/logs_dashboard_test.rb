require "rails_helper"

class LogsDashboardTest < ActionDispatch::SystemTestCase
  include Passkit::Engine.routes.url_helpers

  setup do
    @routes = Passkit::Engine.routes
  end

  def authorize
    visit "http://#{Passkit.configuration.dashboard_username}:#{Passkit.configuration.dashboard_password}@#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/passkit/dashboard/logs"
  end

  test "visiting the logs dashboard" do
    Passkit::Log.create!(content: "[today] shit happened")
    Passkit::Log.create!(content: "[tomorrow] shit will happen")

    authorize

    visit dashboard_logs_path

    assert_selector "h1", text: "Passkit Logs"
    assert_content "shit happened"
    assert_content "shit will happen"
    assert_no_content "today"
    assert_no_content "tomorrow"
  end
end
