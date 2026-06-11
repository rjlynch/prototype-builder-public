Rails.application.routes.draw do
  root "landings#show"

  resource :session, only: %i[create destroy]
  resources :wizards, only: %i[index]

  get "up" => "rails/health#show", as: :rails_health_check
end
