require "rails_helper"

RSpec.describe "Managing pages", :js, type: :system do
  it "deletes pages, keeping at least one" do
    build_three_page_wizard

    # Delete the middle page from its own builder
    within_nav { click_link "second" }
    expect(page).to have_field("Page slug", with: "second")
    accept_confirm { click_button "Delete this page" }

    # Lands on the previous page; the deleted page is gone from the nav
    expect(page).to have_field("Page slug", with: "first")
    within_nav { expect(page).to have_no_text("second") }

    # Linear navigation follows the renumbered positions
    within_preview { click_button "Continue" }
    expect(page).to have_field("Page slug", with: "third")

    # Deleting down to one page removes the option entirely
    accept_confirm { click_button "Delete this page" }
    expect(page).to have_field("Page slug", with: "first")
    expect(page).to have_no_button("Delete this page")
  end

  def build_three_page_wizard
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    expect(page).to have_no_button("Delete this page") # single page is undeletable

    %w[First Second Third].each_with_index do |title, index|
      fill_in "Page title", with: title
      within_preview { expect(page).to have_css("h1", text: title) }
      next if index == 2

      add_component "Add continue button"
      within_preview { click_button "Continue" }
      expect(page).to have_field("Page slug", with: "page-#{index + 2}")
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
