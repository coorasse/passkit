module Passkit
  module Dashboard
    class LogsController < ApplicationController
      def index
        @logs = Passkit::Log.order(created_at: :desc).first(100)
      end
    end
  end
end
