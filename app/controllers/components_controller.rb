class ComponentsController < ApplicationController
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

    # Preview only: the user is mid-typing in the builder pane, so leave it alone.
    respond_with_panes(component.page, builder: false)
  end

  def destroy
    component = Component.find(params[:id])
    component.destroy!

    respond_with_panes(component.page, builder: true)
  end

  private

  def component_params
    params.require(:component).permit(:text, :name, :label, :hint)
  end

  def respond_with_panes(page, builder:)
    respond_to do |format|
      format.turbo_stream do
        streams = [
          turbo_stream.replace(
            helpers.dom_id(page, :preview),
            partial: "pages/preview",
            locals: { page: page, mode: :builder }
          )
        ]
        if builder
          streams << turbo_stream.replace(
            helpers.dom_id(page, :builder),
            partial: "pages/builder",
            locals: { page: page }
          )
        end
        render turbo_stream: streams
      end
      format.html { redirect_to edit_page_path(page) }
    end
  end
end
