module Passkit
  module Api
    module V1
      class PassesController < ActionController::API
        before_action :decrypt_payload, only: :create

        def create
          send_file(fetch_pass(@payload), type: 'application/vnd.apple.pkpass', disposition: 'attachment')
        end

        # @return If request is authorized, returns HTTP status 200 with a payload of the pass data.
        # @return If the request is not authorized, returns HTTP status 401.
        # @return Otherwise, returns the appropriate standard HTTP status.
        def show
          authentication_token = request.headers["Authorization"]&.split(" ")&.last
          unless authentication_token.present?
            render json: {}, status: :unauthorized
            return
          end

          pass = Pass.find_by(serial_number: params[:serial_number], authentication_token: authentication_token)
          unless pass
            render json: {}, status: :unauthorized
            return
          end

          pass_output_path = Passkit::Generator.new(pass).generate_and_sign

          response.headers["last-modified"] = pass.last_update.strftime("%Y-%m-%d %H:%M:%S")
          if request.headers["If-Modified-Since"].nil? ||
              (pass.last_update.to_i > Time.zone.parse(request.headers["If-Modified-Since"]).to_i)
            send_file(pass_output_path, type: 'application/vnd.apple.pkpass', disposition: 'attachment')
          else
            head :not_modified
          end
        end

        private

        def decrypt_payload
          @payload = Passkit::UrlEncrypt.decrypt(params[:payload])
          if DateTime.parse(@payload[:valid_until]).past?
            head :not_found
          end
        end

        def fetch_pass(payload)
          generator = nil
          if payload[:generator_class].present? && payload[:generator_id].present?
            generator_class = payload[:generator_class].constantize
            generator = generator_class.find(payload[:generator_id])
          end
          Passkit::Factory.create_pass(payload[:pass_class], generator)
        end
      end
    end
  end
end
