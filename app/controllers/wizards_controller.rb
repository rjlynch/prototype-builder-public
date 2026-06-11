class WizardsController < ApplicationController
  before_action :require_sign_in

  def index
    render :index, locals: { wizards: Wizard.order(:created_at) }
  end

  def create
    form = WizardForm.new(name: "Untitled wizard")

    if form.save
      redirect_to edit_page_path(form.first_page)
    else
      redirect_to wizards_path, alert: "Could not create a wizard"
    end
  end
end
