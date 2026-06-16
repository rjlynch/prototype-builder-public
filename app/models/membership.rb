# Joins a user to a team. Its existence is what grants the user access to the
# team's wizards.
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id, uniqueness: { scope: :team_id }
end
