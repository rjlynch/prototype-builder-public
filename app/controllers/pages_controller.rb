class PagesController < ApplicationController
  before_action :require_sign_in, except: %i[show]

  # Run mode: one page of a shared prototype, navigable via its continue
  # button. No builder chrome.
  def show
    page = Page.find(params[:id])
    render :show, locals: { page: page }
  end

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
    attrs = params.require(:page).permit(:title, :slug)
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
            helpers.dom_id(page, :slug_heading),
            partial: "pages/slug_heading",
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
