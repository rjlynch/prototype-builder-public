require "rails_helper"

RSpec.describe "Managing pages", :js, type: :system do
  it "deletes pages, keeping at least one" do
    build_three_page_wizard
    click_link "Untitled wizard"

    # Delete the middle page from its own builder
    within_nav { click_link "second" }
    expect(page).to have_css(".app-disclosure__summary", text: "Slug second")
    accept_confirm { click_button "Remove this page" }

    # Lands on the previous page; the deleted page is gone from the nav
    expect(page).to have_css(".app-disclosure__summary", text: "Slug first")
    click_link "Untitled wizard"
    within_nav { expect(page).to have_no_text("second") }

    # Linear navigation follows the renumbered positions
    click_link "first"
    within_preview { click_button "Continue" }
    expect(page).to have_css(".app-disclosure__summary", text: "Slug third")

    # Deleting down to one page removes the option entirely
    accept_confirm { click_button "Remove this page" }
    expect(page).to have_css(".app-disclosure__summary", text: "Slug first")
    click_link "Untitled wizard"
    expect(page).to have_no_button("Remove this page")
  end

  it "reorders pages from the nav" do
    build_three_page_wizard
    click_link "Untitled wizard"

    # We are on "third"; pull it one position earlier
    click_button "Move third earlier"

    within_nav do
      expect(page).to have_css("li:nth-child(2)", text: "third")
      expect(page).to have_css("li:nth-child(3)", text: "second")
    end

    # Linear navigation follows the new order
    within_nav { click_link "first" }
    within_preview { click_button "Continue" }
    expect(page).to have_css(".app-disclosure__summary", text: "Slug third")

    # And back again with the down arrow
    click_link "Untitled wizard"
    click_button "Move third later"
    within_nav do
      expect(page).to have_css("li:nth-child(2)", text: "second")
      expect(page).to have_css("li:nth-child(3)", text: "third")
    end

    # No moving off either end of the journey
    expect(page).to have_no_button("Move first earlier")
    expect(page).to have_no_button("Move third later")
  end

  def build_three_page_wizard
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    expect(page).to have_no_button("Remove this page") # single page is undeletable

    %w[First Second Third].each_with_index do |title, index|
      fill_in "Page title", with: title
      within_preview { expect(page).to have_css("h1", text: title) }
      next if index == 2

      add_component "Add continue button"
      within_preview { click_button "Continue" }
      expect(page).to have_css(".app-disclosure__summary", text: "Slug page-#{index + 2}")
    end
  end

  def within_nav(&block)
    within("nav[aria-label='Pages in this wizard']", &block)
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def add_component(button_label)
    count = all(".app-card", minimum: 0).size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
