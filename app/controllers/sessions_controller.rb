class SessionsController < ApplicationController
  # GET /session/new?token=... — the magic-link landing page. Shows a button
  # that POSTs the token to #create, so following the link (e.g. an email
  # scanner prefetching it) never signs anyone in on its own.
  def new
    @token = params[:token]
  end

  # POST /session — consume the token and sign in. Invalid and expired tokens
  # are treated the same.
  def create
    user = User.find_by_token_for(:sign_in, params[:token])

    if user
      sign_in(user)
      user.record_sign_in!
      redirect_to wizards_path, notice: "You are signed in"
    else
      redirect_to new_sign_in_path, alert: "That sign-in link is invalid or has expired"
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "You are signed out"
  end
end
