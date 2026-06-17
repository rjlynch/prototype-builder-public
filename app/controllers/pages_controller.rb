class PagesController < ApplicationController
  before_action :require_sign_in, except: %i[show]

  # Run mode: one page of a shared prototype, navigable via its continue
  # button. No builder chrome.
  def show
    page = Page.find(params[:id])
    render :show, locals: { page: page }, layout: "run"
  end

  # The page builder: left pane of controls, right pane of live preview.
  def edit
    page = Page.find(params[:id])
    authorize page
    render :edit, locals: { page: page }
  end

  def destroy
    page = Page.find(params[:id])
    authorize page
    form = DeletePageForm.new(page)

    if form.save
      redirect_to edit_page_path(form.destination), status: :see_other
    else
      redirect_to edit_page_path(page), alert: "The only page in a wizard cannot be deleted"
    end
  end

  def update
    page = Page.find(params[:id])
    authorize page
    attrs = params.require(:page).permit(:title, :slug, :heading_size, :caption, :back_link, :panel_style)
    form = PageForm.new(page, params: attrs)
    form.save

    respond_to do |format|
      format.turbo_stream do
        streams = [
          turbo_stream.replace(
            helpers.dom_id(page, :preview),
            partial: "pages/preview",
            locals: { page: page, mode: :builder }
          ),
          turbo_stream.replace(
            helpers.dom_id(page, :pages_nav),
            partial: "pages/pages_nav",
            locals: { page: page }
          )
        ]
        # Refresh the slug field when the title changed it — but never while
        # the user is typing in the slug field itself.
        unless attrs.key?(:slug)
          streams << turbo_stream.replace(
            helpers.dom_id(page, :slug_form),
            partial: "pages/slug_form",
            locals: { page: page }
          )
        end
        # Toggling the panel changes which components offer an "in the panel"
        # checkbox, so re-render the builder pane — but only on that change, so
        # typing in the title never steals focus from the editor cards.
        if page.previous_changes.key?("panel_style")
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
