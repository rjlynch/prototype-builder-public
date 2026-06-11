class BranchRulesController < ApplicationController
  include RendersBuilderPanes

  before_action :require_sign_in

  def create
    component = Component.find(params[:component_id])
    form = AddBranchRuleForm.new(component: component)
    form.save

    respond_with_panes(component.page, builder: true)
  end

  def update
    branch_rule = BranchRule.find(params[:id])
    form = BranchRuleForm.from_branch_rule(branch_rule)
    form.assign_attributes(branch_rule_params)
    form.save

    # Preview only: the user is mid-typing in the rule's fields.
    respond_with_panes(branch_rule.component.page, builder: false)
  end

  def destroy
    branch_rule = BranchRule.find(params[:id])
    branch_rule.destroy!

    respond_with_panes(branch_rule.component.page, builder: true)
  end

  private

  def branch_rule_params
    params.require(:branch_rule).permit(:input_name, :value, :target_slug)
  end
end
