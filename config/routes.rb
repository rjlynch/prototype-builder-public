Rails.application.routes.draw do
  root "landings#show"

  # Request a magic link: new = email form, create = send the email then
  # redirect to show = the neutral "check your email" confirmation.
  resource :sign_in, only: %i[new create show]

  # Register: new = name + email form, create = send a confirmation link then
  # redirect to show = the same neutral "check your email" confirmation.
  resource :sign_up, only: %i[new create show]

  resource :documentation, only: :show, controller: "documentation"

  # The session itself: new = the magic-link confirmation page, create = consume
  # the token and sign in, destroy = sign out.
  resource :session, only: %i[new create destroy]

  # Confirming a sign up: new = the confirmation page reached from the email,
  # create = consume the token, create the account and sign in.
  resource :activation, only: %i[new create]

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

  resources :branch_rules, only: %i[update destroy] do
    resources :conditions, only: %i[create]
  end

  resources :conditions, only: %i[update destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
