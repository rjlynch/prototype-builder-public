# An account. Wizards belong to a team; users join teams through memberships,
# so the same user can belong to several teams.
class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :wizards, dependent: :destroy

  validates :name, presence: true
end
