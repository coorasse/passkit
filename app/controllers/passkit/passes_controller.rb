module Passkit
  class PassesController < ActionController::Base
    layout "passkit/application"

    def index
      @passes = Passkit::Pass.order(created_at: :desc).includes(:devices).first(100)
    end
  end
end
