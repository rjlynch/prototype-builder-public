Rails.application.routes.draw do
  root "landings#show"

  # Request a magic link (new = email form, create = send the email).
  resource :sign_in, only: %i[new create]

  # The session itself: new = the magic-link confirmation page, create = consume
  # the token and sign in, destroy = sign out.
  resource :session, only: %i[new create destroy]

  resources :wizards, only: %i[index create show edit update]

  resources :pages, only: %i[show edit update destroy] do
    resources :components, only: %i[create]
    resource :answers, only: %i[create]
    resource :position, only: %i[update]
    resource :successor, only: %i[create]
  end

  resources :components, only: %i[update destroy] do
    resource :position, only: %i[update], controller: "component_positions"
    resources :branch_rules, only: %i[create]
  end

  resources :branch_rules, only: %i[update destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
