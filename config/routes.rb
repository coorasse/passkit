# frozen_string_literal: true

Passkit::Engine.routes.draw do
  scope :api, constraints: {pass_type_id: /.*/} do
    scope :v1 do
      resources :devices, only: [] do
        post "registrations/:pass_type_id/:serial_number" => "api/v1/registrations#create", :as => :register
        delete "registrations/:pass_type_id/:serial_number" => "api/v1/registrations#destroy", :as => :unregister
        get "registrations/:pass_type_id" => "api/v1/registrations#show", :as => :registrations
      end
      get "passes/:pass_type_id/:serial_number" => "api/v1/passes#show", :as => :pass
      get "passes/:payload", to: "api/v1/passes#create", as: :passes_api
      post "log" => "api/v1/logs#create", :as => :log
    end
  end

  unless Rails.env.production?
    resources :previews, only: [:index, :show], param: :class_name
    resources :logs, only: [:index]
    resources :passes, only: [:index]
  end
end
