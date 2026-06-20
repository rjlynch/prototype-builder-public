class ConditionsController < ApplicationController
  include RendersBuilderPanes

  before_action :require_sign_in

  def create
    branch_rule = BranchRule.find(params[:branch_rule_id])
    authorize branch_rule.component, :update?
    form = AddConditionForm.new(branch_rule: branch_rule)
    form.save

    respond_with_panes(branch_rule.component.page, builder: true)
  end

  def update
    condition = Condition.find(params[:id])
    authorize condition.branch_rule.component, :update?
    form = ConditionForm.from_condition(condition)
    form.assign_attributes(condition_params)
    form.save

    # Completing a condition can change which rule fires, and whether the
    # button is still a dead end, so refresh the preview. The builder pane is
    # left alone so autosubmit never steals focus mid-edit.
    page = condition.branch_rule.component.page
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(page, :preview),
          partial: "pages/preview",
          locals: { page: page, mode: :builder }
        )
      end
      format.html { redirect_to edit_page_path(page) }
    end
  end

  def destroy
    condition = Condition.find(params[:id])
    authorize condition.branch_rule.component, :update?
    condition.destroy!

    respond_with_panes(condition.branch_rule.component.page, builder: true)
  end

  private

  def condition_params
    params.require(:condition).permit(:input_name, :value)
  end
end
