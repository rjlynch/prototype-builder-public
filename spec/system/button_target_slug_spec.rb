require "rails_helper"

# A button can name the page it goes to, so a journey routes correctly even
# when pages have been reordered (linear "next by position" is not always
# right). A matching branch rule still takes priority; a blank slug falls
# back to the next page.
RSpec.describe "Button target slug", :js, type: :system do
  it "routes to the named page instead of the next one" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Start"
    add_component "Add button"

    within_last_card do
      fill_in "Go to page", with: "Check your answers"
      # The hint is the server-rendered confirmation that the slug saved.
      expect(page).to have_content("This page does not exist yet.")
    end

    # Clicking the button creates the named page (builder mode) and lands there,
    # skipping the linear "page-2" the journey would otherwise have created.
    within_preview { click_button "Continue" }
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls check-your-answers")
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def add_component(button_label)
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
