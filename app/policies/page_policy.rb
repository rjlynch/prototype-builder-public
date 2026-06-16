# Editing a page is editing the wizard it belongs to, so access follows team
# membership of the wizard's team. The public run view (PagesController#show) is
# unauthenticated and does not go through this policy.
class PagePolicy < ApplicationPolicy
  def edit? = member_of_owning_team?
  def update? = member_of_owning_team?
  def destroy? = member_of_owning_team?

  private

  def member_of_owning_team?
    user.present? && user.teams.exists?(record.wizard.team_id)
  end
end
