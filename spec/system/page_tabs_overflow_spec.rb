require "rails_helper"

RSpec.describe "Page tabs overflow", :js, type: :system do
  it "collapses overflowing tabs into an arrow that jumps to a hidden page" do
    sign_in
    click_button "New wizard"

    # Build five pages, leaving us on the last (the rightmost tab).
    %w[First Second Third Fourth Fifth].each_with_index do |title, index|
      fill_in "Page title", with: title
      within_preview { expect(page).to have_css("h1", text: title) }
      next if index == 4

      add_button
      within_preview { click_button "Continue" }
      expect(page).to have_css(".app-disclosure__summary", text: "Slug page-#{index + 2}")
    end

    # Squeeze the viewport so the row can't hold every tab on a single line.
    page.current_window.resize_to(500, 800)

    within_nav do
      expect(page).to have_link("Show earlier pages") # an arrow rides in its own tab
      expect(page).to have_no_link("First")           # the furthest tab is hidden
    end

    # Following the arrow jumps to the nearest hidden (earlier) page.
    within_nav { click_link "Show earlier pages" }
    expect(page).to have_no_css(".app-disclosure__summary", text: "Slug fifth")
  end

  def add_button
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button "Add button"
    expect(page).to have_css(".app-card", count: count + 1)
  end

  def within_nav(&block)
    within("nav[aria-label='Pages in this wizard']", &block)
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end
end
