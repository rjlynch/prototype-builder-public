class WizardsController < ApplicationController
  before_action :require_sign_in, except: %i[show]

  # The share link: anyone with the URL can walk through the prototype,
  # starting at its first page.
  def show
    wizard = Wizard.find(params[:id])
    redirect_to page_path(wizard.pages.first!)
  end

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
