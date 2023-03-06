module Passkit
  module Api
    module V1
      # TODO: check with authentication_token
      # This Class Implements the Apple PassKit API
      # @see Apple: https://developer.apple.com/library/archive/documentation/PassKit/Reference/PassKit_WebService/WebService.html
      # @see Android: https://walletpasses.io/developer/
      class RegistrationsController < ActionController::API
        before_action :load_pass, only: %i[create destroy]
        before_action :load_device, only: %i[show]

        # @return If the serial number is already registered for this device, returns HTTP status 200.
        # @return If registration succeeds, returns HTTP status 201.
        # @return If the request is not authorized, returns HTTP status 401.
        # @return Otherwise, returns the appropriate standard HTTP status.
        def create
          if @pass.devices.find_by(identifier: params[:device_id])
            render json: {}, status: :ok
            return
          end

          register_device
          render json: {}, status: :created
        end

        # @return If there are matching passes, returns HTTP status 200
        #         with a JSON dictionary with the following keys and values:
        #         lastUpdated (string): The current modification tag.
        #         serialNumbers (array of strings): The serial numbers of the matching passes.
        # @return If there are no matching passes, returns HTTP status 204.
        # @return Otherwise, returns the appropriate standard HTTP status
        def show
          if @device.nil?
            render json: {}, status: :not_found
            return
          end

          passes = fetch_registered_passes
          if passes.none?
            render json: {}, status: :no_content
            return
          end

          render json: updatable_passes(passes).to_json
        end

        # @return If disassociation succeeds, returns HTTP status 200.
        # @return If the request is not authorized, returns HTTP status 401.
        # @return Otherwise, returns the appropriate standard HTTP status.
        def destroy
          registrations = @pass.registrations.where(passkit_device_id: params[:device_id])
          registrations.delete_all
          render json: {}, status: :ok
        end

        private

        def load_pass
          authentication_token = request.headers["Authorization"]&.split(" ")&.last
          unless authentication_token.present?
            render json: {}, status: :unauthorized
            return
          end

          @pass = Pass.find_by(serial_number: params[:serial_number], authentication_token: authentication_token)
          unless @pass
            render json: {}, status: :unauthorized
          end
        end

        def load_device
          @device = Passkit::Device.find_by(identifier: params[:device_id])
        end

        def register_device
          device = Passkit::Device.find_or_create_by!(identifier: params[:device_id]) { |d| d.push_token = push_token }
          @pass.registrations.create!(device: device)
        end

        def fetch_registered_passes
          passes = @device.passes

          if params[:passesUpdatedSince]&.present?
            passes.all.filter { |a| a.last_update >= Date.parse(params[:passesUpdatedSince]) }
          else
            passes
          end
        end

        def updatable_passes(passes)
          {lastUpdated: Time.zone.now, serialNumbers: passes.pluck(:serial_number)}
        end

        # TODO: add authentication_token
        # The value is the word ApplePass, followed by a space
        # The value is the word AndroidPass (instead of ApplePass), followed by a space
        def authentication_token
          ""
        end

        def push_token
          return unless request&.body

          request.body.rewind
          json_body = JSON.parse(request.body.read)
          json_body["pushToken"]
        end
      end
    end
  end
end
