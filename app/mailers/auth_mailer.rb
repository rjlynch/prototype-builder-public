# Sign-in emails. Plain text only (no HTML part) — see the .text.erb templates.
class AuthMailer < ApplicationMailer
  # The magic link that signs an existing user in. The token is self-expiring
  # (15 minutes) and single-use (invalidated once they sign in).
  def sign_in_link(user)
    @url = new_session_url(token: user.generate_token_for(:sign_in))
    mail(to: user.email_address, subject: "Sign in to GOV.UK Prototype Builder")
  end

  # The link that confirms a sign up and creates the account. Self-expiring
  # (15 minutes) and single-use (consumed when the signup is activated).
  def activate_signup(signup)
    @url = new_activation_url(token: signup.generate_token_for(:activation))
    mail(to: signup.email_address, subject: "Confirm your GOV.UK Prototype Builder account")
  end

  # Sent when someone asks to sign in with an email that has no account. Points
  # them at sign up (pre-filling the address). We still respond so the sign-in
  # form can stay neutral about who is registered.
  def no_account(email_address)
    @email_address = email_address
    @url = new_sign_up_url(email_address: email_address)
    mail(to: email_address, subject: "No GOV.UK Prototype Builder account yet")
  end
end
