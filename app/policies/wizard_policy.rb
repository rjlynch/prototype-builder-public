class WizardPolicy < ApplicationPolicy
  def index? = true
  def create? = user.present?
  def edit? = member_of_owning_team?
  def update? = member_of_owning_team?

  private

  # Access follows team membership: a user may act on any wizard owned by a team
  # they belong to. Which of their teams is "current" is a navigation concern
  # the controller layers on top (it filters the dashboard); it is deliberately
  # not encoded here. The public share link (WizardsController#show) is
  # unauthenticated and does not go through this policy.
  def member_of_owning_team?
    user.present? && user.teams.exists?(record.team_id)
  end

  # Every wizard belonging to a team the user is a member of.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.nil?

      scope.joins(team: :users).where(users: { id: user.id })
    end
  end
end
