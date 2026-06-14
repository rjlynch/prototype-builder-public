class ComponentPositionsController < ApplicationController
  include RendersBuilderPanes

  before_action :require_sign_in

  def update
    component = Component.find(params[:component_id])
    form = MoveComponentForm.new(component: component, direction: params.require(:direction))
    form.save

    # The form loaded (and so cached) page.components before reordering, leaving
    # the in-memory association in the old order; reload it so the re-rendered
    # panes reflect the new positions.
    component.page.components.reload
    respond_with_panes(component.page, builder: true)
  end
end
