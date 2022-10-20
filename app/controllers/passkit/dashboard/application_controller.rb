module Passkit
  module Dashboard
    class ApplicationController < ActionController::Base
      layout "passkit/application"

      before_action :_authenticate_dashboard!

      private

      def _authenticate_dashboard!
        instance_eval(&Passkit.configuration.authenticate_dashboard_with)
      end
    end
  end
end
