Rails.application.routes.draw do
  root "landings#show"

  resource :session, only: %i[create destroy]

  resources :wizards, only: %i[index create show edit update]

  resources :pages, only: %i[show edit update destroy] do
    resources :components, only: %i[create]
    resource :answers, only: %i[create]
    resource :position, only: %i[update]
    resource :successor, only: %i[create]
  end

  resources :components, only: %i[update destroy] do
    resources :branch_rules, only: %i[create]
  end

  resources :branch_rules, only: %i[update destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
