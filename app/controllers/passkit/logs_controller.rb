module Passkit
  class LogsController < ActionController::Base
    layout "passkit/application"

    def index
      @logs = Passkit::Log.order(created_at: :desc).first(100)
    end
  end
end
