# Requesting a magic link: the email form and sending the email.
class SignInsController < ApplicationController
  # GET /sign_in/new — the email entry form.
  def new
  end

  # POST /sign_in — email submitted. Email an existing user a magic link, or
  # anyone else a "no account yet" note, then redirect to the same neutral
  # confirmation either way so the form never reveals who is registered.
  # Redirecting (rather than rendering) keeps Turbo happy and follows PRG.
  def create
    email_address = params[:email_address].to_s.strip

    if email_address.present?
      if (user = User.find_by(email_address: email_address))
        AuthMailer.sign_in_link(user).deliver_later
      else
        AuthMailer.no_account(email_address).deliver_later
      end
    end

    redirect_to sign_in_path
  end

  # GET /sign_in — the neutral "check your email" confirmation.
  def show
  end
end
