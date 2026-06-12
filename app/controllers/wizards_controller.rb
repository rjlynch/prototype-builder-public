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

  # Wizard-level settings, kept off the page builder.
  def edit
    render :edit, locals: { wizard: Wizard.find(params[:id]) }
  end

  def update
    wizard = Wizard.find(params[:id])
    form = WizardNameForm.new(wizard: wizard, name: params.require(:wizard)[:name])
    form.save

    respond_to do |format|
      # The user is mid-typing in the name field — refresh only the page
      # heading, which echoes the saved name back without stealing focus.
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(wizard, :name_heading),
          partial: "wizards/name_heading",
          locals: { wizard: wizard }
        )
      end
      format.html { redirect_to edit_wizard_path(wizard) }
    end
  end
end
