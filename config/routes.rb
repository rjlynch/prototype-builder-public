Rails.application.routes.draw do
  root "landings#show"

  resource :session, only: %i[create destroy]

  resources :wizards, only: %i[index create show] do
    resources :pages, only: %i[create]
  end

  resources :pages, only: %i[show edit update] do
    resources :components, only: %i[create]
  end

  resources :components, only: %i[update destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
