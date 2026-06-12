# Shared turbo-stream response for builder mutations: always refresh the
# preview pane; refresh the builder pane too unless the user is mid-typing
# in it (updates from autosubmit fields must never steal focus).
module RendersBuilderPanes
  private

  def respond_with_panes(page, builder:, extra_streams: [])
    respond_to do |format|
      format.turbo_stream do
        streams = [
          turbo_stream.replace(
            helpers.dom_id(page, :preview),
            partial: "pages/preview",
            locals: { page: page, mode: :builder }
          ),
          *extra_streams
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
