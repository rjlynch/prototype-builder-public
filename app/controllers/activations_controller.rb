# Confirming a sign up from the emailed link.
class ActivationsController < ApplicationController
  # GET /activation/new?token=... — the confirmation page. A button POSTs the
  # token to #create, so an email scanner prefetching the link can't create an
  # account on its own (mirrors the sign-in confirmation step).
  def new
    @token = params[:token]
  end

  # POST /activation — consume the token, create the account and sign in.
  # Invalid and expired links are treated the same.
  def create
    signup = Signup.find_by_token_for(:activation, params[:token])

    if signup
      user = signup.activate!
      sign_in(user)
      user.record_sign_in!
      redirect_to wizards_path, notice: "Your account is ready"
    else
      redirect_to new_sign_up_path, alert: "That link is invalid or has expired"
    end
  end
end
