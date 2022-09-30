Rails.application.routes.draw do
  mount Passkit::Engine => "/passkit"
end
