class User < ApplicationRecord
  # PII: encrypted at rest. email_address is deterministic so we can still look
  # a user up by it (magic-link sign in) and enforce the unique index;
  # full_name is non-deterministic as we never query on it. downcase: true
  # normalises the email before encrypting so the unique index and lookups are
  # case-insensitive.
  encrypts :email_address, deterministic: true, downcase: true
  encrypts :full_name

  # The team the user is currently working in. New users default to their own
  # Personal Team.
  belongs_to :default_team, class_name: "Team"

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  normalizes :email_address, with: ->(email) { email.strip }

  # Stop two users sharing an email address (also guarded by the unique index).
  validates :email_address, presence: true, uniqueness: true
  validates :full_name, presence: true

  # Convenience for "the team this user is acting in right now".
  def current_team
    default_team
  end
end
