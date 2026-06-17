# Editing a component — its content, its position, or the branch rules on it — is
# editing the wizard it belongs to, so access follows team membership of that
# wizard's team, like PagePolicy and WizardPolicy. Components are only reached
# through the authenticated builder; they have no public view.
class ComponentPolicy < ApplicationPolicy
  def update? = member_of_owning_team?
  def destroy? = member_of_owning_team?

  private

  def member_of_owning_team?
    user.present? && user.teams.exists?(record.page.wizard.team_id)
  end
end
