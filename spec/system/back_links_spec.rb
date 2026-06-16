require "rails_helper"

# Issue #38: every page after the first gets a GOV.UK back link, which can be
# turned off per page. The link returns through browser history, so it lands on
# the page the visitor actually came from even when branch rules skipped pages.
RSpec.describe "Back links", type: :system do
  it "shows a back link on pages after the first, but not on the first page" do
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    first = wizard.pages.create!(position: 1, slug: "start", title: "Start")
    second = wizard.pages.create!(position: 2, slug: "second", title: "Second")

    visit page_path(first)
    expect(page).to have_no_link("Back")

    visit page_path(second)
    expect(page).to have_link("Back")
  end

  it "can be turned off for an individual page" do
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    wizard.pages.create!(position: 1, slug: "start", title: "Start")
    second = wizard.pages.create!(position: 2, slug: "second", title: "Second", back_link: false)

    visit page_path(second)

    expect(page).to have_no_link("Back")
  end

  describe "with JavaScript", :js do
    it "returns to the page the visitor came from, even when branching skipped pages" do
      wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
      start = wizard.pages.create!(position: 1, slug: "start", title: "Start")
      start.components.create!(position: 1, kind: "radios", name: "question-1", options: "yes\nno")
      button = start.components.create!(position: 2, kind: "button", text: "Continue")
      button.branch_rules.create!(position: 1, input_name: "question-1", value: "yes", target_slug: "finish")
      # A page in between that the "yes" answer skips over.
      wizard.pages.create!(position: 2, slug: "skipped", title: "Skipped")
      wizard.pages.create!(position: 3, slug: "finish", title: "Finish")

      visit wizard_path(wizard)
      expect(page).to have_css("h1", text: "Start")

      choose "yes"
      click_button "Continue"
      expect(page).to have_css("h1", text: "Finish")

      # The position-previous page is "Skipped", but the back link follows
      # browser history straight back to where we actually came from: "Start".
      click_link "Back"
      expect(page).to have_css("h1", text: "Start")
    end

    it "is configured from the page builder and previews live" do
      visit root_path
      click_button "Sign in"

      wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
      wizard.pages.create!(position: 1, slug: "start", title: "Start")
      second = wizard.pages.create!(position: 2, slug: "second", title: "Second")

      visit edit_page_path(second)

      within_preview { expect(page).to have_link("Back") }

      uncheck "Show a back link on this page"
      within_preview { expect(page).to have_no_link("Back") }

      check "Show a back link on this page"
      within_preview { expect(page).to have_link("Back") }
    end

    it "does not offer back link controls on the first page" do
      visit root_path
      click_button "Sign in"

      wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
      first = wizard.pages.create!(position: 1, slug: "start", title: "Start")
      wizard.pages.create!(position: 2, slug: "second", title: "Second")

      visit edit_page_path(first)

      expect(page).to have_no_field("Show a back link on this page")
      within_preview { expect(page).to have_no_link("Back") }
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end
end
