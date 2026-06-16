class WizardPolicy < ApplicationPolicy
  def index? = true
  def create? = current_team.present?
  def edit? = owned?
  def update? = owned?

  private

  # A wizard is editable only by users acting in the team that owns it. The
  # public share link (WizardsController#show) is unauthenticated and does not
  # go through this policy.
  def owned? = current_team.present? && record.team_id == current_team.id

  # Wizards visible in the dashboard are those belonging to the current team.
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user&.current_team.nil?

      scope.where(team: user.current_team)
    end
  end
end
