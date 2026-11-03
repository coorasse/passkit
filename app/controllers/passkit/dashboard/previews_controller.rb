module Passkit
  module Dashboard
    class PreviewsController < ApplicationController
      include Passkit::PassDelivery

      def index
      end

      def show
        builder = Passkit.configuration.available_passes[params[:class_name]]
        path = Factory.create_pass(params[:class_name].constantize, builder.call)

        send_pass_file path, type: "application/vnd.apple.pkpass", filename: "pass.pkpass"
      end
    end
  end
end
