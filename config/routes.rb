Rails.application.routes.draw do
  root "landings#show"

  resource :session, only: %i[create destroy]

  resources :wizards, only: %i[index create] do
    resources :pages, only: %i[create]
  end

  resources :pages, only: %i[edit update]

  get "up" => "rails/health#show", as: :rails_health_check
end
