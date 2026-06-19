require "rails_helper"

# The branching scenario from the brief: an "Are you eligible?" radio
# question whose continue button routes yes -> congratulations and
# no -> you-are-not-eligible.
RSpec.describe "Branching a wizard", :js, type: :system do
  it "routes to different pages depending on a radio answer" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Are you eligible?"
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls are-you-eligible")
    expect(page).to have_field("Page title", with: "Are you eligible?")
    add_component "Add radio buttons"
    within_last_card do
      fill_in "Label", with: "Are you eligible?"
      fill_in "Options (one per line)", with: "yes\nno"
    end
    within_preview do
      expect(page).to have_css(".govuk-radios__label", text: "yes")
      expect(page).to have_css(".govuk-radios__label", text: "no")
    end

    add_component "Add button"

    # First rule: yes -> congratulations
    add_rule
    within_last_rule do
      select "question-1 (Are you eligible?)", from: "When answer to"
      fill_in "Is", with: "yes"
      fill_in "Go to page", with: "congratulations"
      expect(page).to have_content("Saved")
      expect(page).to have_content("This page does not exist yet.")
    end

    # Second rule: no -> you-are-not-eligible
    add_rule
    within_last_rule do
      select "question-1 (Are you eligible?)", from: "When answer to"
      fill_in "Is", with: "no"
      fill_in "Go to page", with: "You are not eligible"
      expect(page).to have_content("Saved")
      expect(page).to have_content("This page does not exist yet.")
    end

    # Answer yes: a blank "congratulations" page is created and we land
    # on its builder
    within_preview do
      choose "yes"
      click_button "Continue"
    end
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls congratulations")
    expect(page).to have_field("Page title", with: "")

    # Back on the question page (the first tab) via the tab menu, answer no
    within_nav { first(".govuk-tabs__tab").click }
    within_preview do
      choose "no"
      click_button "Continue"
    end
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls you-are-not-eligible")
  end

  it "explains that branching needs an input first" do
    sign_in
    click_button "New wizard"

    add_component "Add button"
    add_rule

    within_last_rule do
      expect(page).to have_text("This wizard has no inputs yet")
      expect(page).to have_no_select("When answer to")
    end
  end

  it "updates the missing page warning while typing a branch target" do
    sign_in
    click_button "New wizard"

    add_component "Add radio buttons"
    within_last_card do
      fill_in "Label", with: "Are you eligible?"
      fill_in "Options (one per line)", with: "yes\nno"
    end
    within_preview do
      expect(page).to have_css(".govuk-radios__label", text: "yes")
      expect(page).to have_css(".govuk-radios__label", text: "no")
    end

    add_component "Add button"
    within_preview { click_button "Continue" }
    fill_in "Page title", with: "Existing page"
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls existing-page")

    # Back to the question page (the first tab) via the tab menu
    within_nav { first(".govuk-tabs__tab").click }
    add_rule
    within_last_rule do
      select "question-1 (Are you eligible?)", from: "When answer to"
      fill_in "Is", with: "yes"
      fill_in "Go to page", with: "not-yet-created"
      expect(page).to have_content("This page does not exist yet.")

      fill_in "Go to page", with: "existing-page"
      expect(page).to have_no_content("This page does not exist yet.")
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def within_last_rule(&block)
    within(all(".app-rule").last, &block)
  end

  def within_nav(&block)
    within("nav[aria-label='Pages in this wizard']", &block)
  end

  def add_component(button_label)
    # The page title card is always present, so the builder has settled once
    # at least one card exists; count from there to avoid a mid-render read.
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end

  def add_rule
    count = all(".app-rule", minimum: 0).size
    click_button "Add rule"
    expect(page).to have_css(".app-rule", count: count + 1)
  end
end
