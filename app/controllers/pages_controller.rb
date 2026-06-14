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
    render :edit, locals: { page: page }
  end

  def destroy
    page = Page.find(params[:id])
    form = DeletePageForm.new(page: page)

    if form.save
      redirect_to edit_page_path(form.destination), status: :see_other
    else
      redirect_to edit_page_path(page), alert: "The only page in a wizard cannot be deleted"
    end
  end

  def update
    page = Page.find(params[:id])
    attrs = params.require(:page).permit(:title, :slug, :heading_size, :caption)
    form = PageForm.new(page: page, **attrs.to_h.symbolize_keys)
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
        render turbo_stream: streams
      end
      format.html { redirect_to edit_page_path(page) }
    end
  end
end
