# Registering for an account: the name + email form and sending the
# confirmation link.
class SignUpsController < ApplicationController
  # GET /sign_up/new — the registration form.
  def new
    render :new, locals: { signup: Signup.new(email_address: params[:email_address]) }
  end

  # POST /sign_up — details submitted. Email a confirmation link, then redirect
  # to the neutral confirmation. An address that already has an account gets a
  # sign-in link instead (never a new signup), so the form stays neutral about
  # who is registered. Redirecting (not rendering) follows PRG and keeps Turbo
  # happy; an invalid form re-renders with errors (422, which Turbo shows).
  def create
    signup = Signup.new(signup_params)

    if signup.valid?
      if (user = User.find_by(email_address: signup.email_address))
        AuthMailer.sign_in_link(user).deliver_later
      else
        signup.save!
        AuthMailer.activate_signup(signup).deliver_later
        DestroySignupJob.set(wait: Signup::EXPIRY).perform_later(signup.id)
      end

      redirect_to sign_up_path
    else
      render :new, locals: { signup: signup }, status: :unprocessable_content
    end
  end

  # GET /sign_up — the neutral "check your email" confirmation.
  def show
  end

  private

  def signup_params
    params.require(:signup).permit(:full_name, :email_address)
  end
end
