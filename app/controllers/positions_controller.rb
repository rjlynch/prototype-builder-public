class PositionsController < ApplicationController
  before_action :require_sign_in

  def update
    page = Page.find(params[:page_id])
    authorize page, :update?
    form = MovePageForm.new(page, params: { position: params.require(:position) })
    form.save

    # Reordering happens from the pages nav, which appears on every builder
    # page — stay wherever the user already is.
    redirect_back fallback_location: edit_page_path(page), status: :see_other
  end
end
