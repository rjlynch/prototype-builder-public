require "rails_helper"

# Mirrors the rough spec in the project brief: a non-technical user builds a
# multi-page journey in the page builder while the preview pane updates live.
RSpec.describe "Building a wizard", :js, type: :system do
  it "creates a wizard and edits the first page with a live preview" do
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    expect(page).to have_content("Page 1")
    expect(page).to have_field("Page title")

    fill_in "Page title", with: "Claim an early years teacher recognition payment"

    within_preview do
      expect(page).to have_css("h1", text: "Claim an early years teacher recognition payment")
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end
end
