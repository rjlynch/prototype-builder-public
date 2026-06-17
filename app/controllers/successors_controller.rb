class SuccessorsController < ApplicationController
  before_action :require_sign_in

  # Inserts a new blank page after the given one and lands the user on it,
  # ready to start building.
  def create
    page = Page.find(params[:page_id])
    authorize page, :update?
    form = InsertPageForm.new(page)
    form.save

    redirect_to edit_page_path(form.new_page), status: :see_other
  end
end
