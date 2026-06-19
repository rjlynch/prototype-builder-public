require "rails_helper"

RSpec.describe "Managing pages", :js, type: :system do
  it "deletes pages, keeping at least one" do
    build_three_page_wizard

    # Jump to the middle page via its tab (labels show the first 5 chars)
    within_nav { click_link "Secon" }
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls second")
    open_page_controls
    accept_confirm { click_button "Remove this page" }

    # Lands on the previous page; the deleted page is gone from the nav
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls first")
    within_nav { expect(page).to have_no_text("Secon") }

    # Linear navigation follows the renumbered positions
    within_nav { click_link "First" }
    within_preview { click_button "Continue" }
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls third")

    # Deleting down to one page removes the option entirely
    open_page_controls
    accept_confirm { click_button "Remove this page" }
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls first")
    open_page_controls
    expect(page).to have_no_button("Remove this page")
  end

  it "reorders pages from the page controls" do
    build_three_page_wizard

    # We are on "Third", the last page: it can move back but not forward
    open_page_controls
    expect(page).to have_no_button("Move page forward")
    click_button "Move page back"

    within_nav do
      expect(page).to have_css("li:nth-child(2)", text: "Third")
      expect(page).to have_css("li:nth-child(3)", text: "Secon")
    end

    # Linear navigation follows the new order
    within_nav { click_link "First" }
    within_preview { click_button "Continue" }
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls third")

    # And back again the other way
    open_page_controls
    click_button "Move page forward"
    within_nav do
      expect(page).to have_css("li:nth-child(2)", text: "Secon")
      expect(page).to have_css("li:nth-child(3)", text: "Third")
    end

    # No moving off the end of the journey
    open_page_controls
    expect(page).to have_no_button("Move page forward")
  end

  it "inserts a new page after the current one from the page controls" do
    build_three_page_wizard

    # Insert after the first page; we land on the new blank page's builder
    within_nav { click_link "First" }
    open_page_controls
    click_button "Add page after"
    expect(page).to have_field("Page title", with: "")

    # The new page sits between First and Second, shifting the rest down
    within_nav do
      expect(page).to have_css("li", count: 4)
      expect(page).to have_css("li:nth-child(1)", text: "First")
      expect(page).to have_css("li:nth-child(2).govuk-tabs__list-item--selected")
      expect(page).to have_css("li:nth-child(3)", text: "Secon")
      expect(page).to have_css("li:nth-child(4)", text: "Third")
    end
  end

  def build_three_page_wizard
    sign_in
    click_button "New wizard"

    open_page_controls
    expect(page).to have_no_button("Remove this page") # single page is undeletable

    %w[First Second Third].each_with_index do |title, index|
      fill_in "Page title", with: title
      within_preview { expect(page).to have_css("h1", text: title) }
      next if index == 2

      add_component "Add button"
      within_preview { click_button "Continue" }
      expect(page).to have_css(".app-disclosure__summary", text: "Page controls page-#{index + 2}")
    end
  end

  def within_nav(&block)
    within("nav[aria-label='Pages in this wizard']", &block)
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  # The page controls (slug, reorder, insert, remove) live in a collapsed
  # disclosure; open it before reaching for those buttons. "Add page after" is
  # always rendered, so its visibility tells us whether the disclosure is open.
  def open_page_controls
    return if has_button?("Add page after", wait: 0)

    find(".app-disclosure__summary").click
    expect(page).to have_button("Add page after")
  end

  def add_component(button_label)
    # The page title card is always present, so the builder has settled once
    # at least one card exists; count from there to avoid a mid-render read.
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
