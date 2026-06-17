class ComponentsController < ApplicationController
  include RendersBuilderPanes

  before_action :require_sign_in

  def create
    page = Page.find(params[:page_id])
    authorize page, :update?
    form = AddComponentForm.new(page: page, kind: params.require(:component)[:kind])
    form.save

    respond_with_panes(page, builder: true)
  end

  def update
    component = Component.find(params[:id])
    authorize component, :update?
    form = ComponentForm.from_component(component)
    form.assign_attributes(component_params)
    form.save

    # Preview only: the user is mid-typing in the builder pane, so leave it
    # alone. Exception: toggling title_as_label changes which fields the
    # editors show, and a checkbox click is not typing — re-render the lot.
    respond_with_panes(component.page, builder: component.previous_changes.key?("title_as_label"))
  end

  def destroy
    component = Component.find(params[:id])
    authorize component, :destroy?
    component.destroy!

    respond_with_panes(component.page, builder: true)
  end

  private

  def component_params
    params.require(:component).permit(:text, :name, :label, :hint, :options, :title_as_label,
      :list_style, :list_spaced, :button_style)
  end
end
