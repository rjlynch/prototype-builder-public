# Editing a page is editing the wizard it belongs to, so access follows the
# wizard's team. The public run view (PagesController#show) is unauthenticated
# and does not go through this policy.
class PagePolicy < ApplicationPolicy
  def edit? = owned?
  def update? = owned?
  def destroy? = owned?

  private

  def owned? = current_team.present? && record.wizard.team_id == current_team.id
end
