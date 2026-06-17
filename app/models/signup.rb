class Signup < ApplicationRecord
  # How long a confirmation link is valid, and how long a pending signup lives
  # before DestroySignupJob cleans it up. Kept the same so an unconfirmed signup
  # and its link expire together.
  EXPIRY = 15.minutes

  # PII, encrypted at rest like User. email_address is deterministic + downcase
  # so confirming can look the address up against existing users; full_name is
  # non-deterministic as we never query on it.
  encrypts :email_address, deterministic: true, downcase: true
  encrypts :full_name

  # The confirmation link's token: a signed, self-expiring reference to this
  # pending signup. Single use comes from destroying the record on activation
  # (and the cleanup job), so a consumed or expired link no longer resolves.
  generates_token_for :activation, expires_in: EXPIRY

  normalizes :email_address, with: ->(email) { email.strip }

  # No uniqueness on email_address: two pending signups for the same address are
  # harmless (each confirms to the same account, and User's unique index stops a
  # second one), and a unique index here would leak who is already registered.
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true

  # Turn a confirmed signup into a real account — a Personal Team, the user, and
  # their membership of it — then consume the signup. Idempotent on the email: if
  # an account already exists (e.g. the link was opened twice) it returns that
  # user rather than tripping the unique index.
  def activate!
    user = User.find_by(email_address: email_address) || create_account
    destroy
    user
  end

  private

  def create_account
    Signup.transaction do
      team = Team.create!(name: "Personal Team")
      user = User.create!(email_address: email_address, full_name: full_name, default_team: team)
      Membership.create!(user: user, team: team)
      user
    end
  end
end
