class PagesController < ApplicationController
  before_action :require_sign_in

  # The continue button in the builder preview: find or create the page that
  # follows the given one, then take the user to its builder.
  def create
    wizard = Wizard.find(params[:wizard_id])
    form = NextPageForm.new(page: wizard.pages.find(params[:after_id]))

    if form.save
      redirect_to edit_page_path(form.next_page)
    else
      redirect_to wizards_path, alert: "Could not add a page"
    end
  end

  # The page builder: left pane of controls, right pane of live preview.
  def edit
    page = Page.find(params[:id])
    render :edit, locals: { page: page }
  end

  def update
    page = Page.find(params[:id])
    form = PageForm.new(page: page, title: params.require(:page)[:title])
    form.save

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(page, :preview),
          partial: "pages/preview",
          locals: { page: page, mode: :builder }
        )
      end
      format.html { redirect_to edit_page_path(page) }
    end
  end
end
