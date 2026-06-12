class ComponentsController < ApplicationController
  include RendersBuilderPanes

  before_action :require_sign_in

  def create
    page = Page.find(params[:page_id])
    form = AddComponentForm.new(page: page, kind: params.require(:component)[:kind])
    form.save

    respond_with_panes(page, builder: true)
  end

  def update
    component = Component.find(params[:id])
    form = ComponentForm.from_component(component)
    form.assign_attributes(component_params)
    form.save

    # Preview only: the user is mid-typing in the builder pane, so leave it
    # alone — except the card's summary line, which echoes what they typed
    # and is safe to refresh (nobody types in a <summary>).
    respond_with_panes(
      component.page,
      builder: false,
      extra_streams: [
        turbo_stream.replace(
          helpers.dom_id(component, :card_summary),
          partial: "components/card_summary",
          locals: { component: component }
        )
      ]
    )
  end

  def destroy
    component = Component.find(params[:id])
    component.destroy!

    respond_with_panes(component.page, builder: true)
  end

  private

  def component_params
    params.require(:component).permit(:text, :name, :label, :hint, :options)
  end
end
