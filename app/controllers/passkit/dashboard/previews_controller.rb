module Passkit
  module Dashboard
    class PreviewsController < ApplicationController
      def index
      end

      def show
        builder = Passkit.configuration.available_passes[params[:class_name]]
        send_file Factory.create_pass(params[:class_name].constantize, builder.call)
      end
    end
  end
end
