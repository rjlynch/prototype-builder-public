require "rails_helper"

# Checkboxes let people select several answers from a list.
# https://design-system.service.gov.uk/components/checkboxes/
RSpec.describe "Checkbox components", :js, type: :system do
  it "previews as GOV.UK checkboxes and branches when a box is ticked" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Which benefits do you get?"
    add_component "Add checkboxes"
    within_last_card do
      fill_in "Label", with: "Which benefits do you get?"
      fill_in "Options (one per line)", with: "Universal Credit\nPersonal Independence Payment"
    end

    within_preview do
      expect(page).to have_css(".govuk-checkboxes", count: 1)
      expect(page).to have_css(".govuk-checkboxes__label", text: "Universal Credit")
      expect(page).to have_css(".govuk-checkboxes__label", text: "Personal Independence Payment")
    end

    add_component "Add button"
    add_rule
    within_last_condition do
      select "question-1 (Which benefits do you get?)", from: "When answer to"
      fill_in "Is", with: "Personal Independence Payment"
      fill_in "Go to page", with: "you-may-be-eligible"
      # The "does not exist yet" notice only renders once the target slug has
      # been saved, so waiting on it confirms the whole rule has persisted.
      expect(page).to have_content("This page does not exist yet.")
    end

    # Tick the matching box: the rule routes us to its (newly created) page
    within_preview do
      check "Personal Independence Payment"
      click_button "Continue"
    end
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls you-may-be-eligible")
  end

  it "carries the checkboxes through to run mode" do
    sign_in
    click_button "New wizard"

    add_component "Add checkboxes"
    within_last_card do
      fill_in "Label", with: "Which benefits do you get?"
      fill_in "Options (one per line)", with: "Universal Credit\nPersonal Independence Payment"
    end
    within_preview { expect(page).to have_css(".govuk-checkboxes__label", text: "Universal Credit") }

    wizard = Wizard.last
    visit page_path(wizard.pages.first)

    # GOV.UK visually hides the input and styles the label, so assert on the
    # rendered checkbox markup rather than a visible field.
    expect(page).to have_css(".govuk-checkboxes[data-module='govuk-checkboxes']")
    expect(page).to have_css(".govuk-checkboxes__label", text: "Universal Credit")
    expect(page).to have_css(".govuk-checkboxes__label", text: "Personal Independence Payment")
    expect(page).to have_css("input[type=checkbox][name='answers[question-1][]']", visible: :all, count: 2)
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    expect(page).to have_css(".app-card", minimum: 1)
    within(all(".app-card").last, &block)
  end

  def within_last_condition(&block)
    within(all(".app-condition").last, &block)
  end

  def add_component(button_label)
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end

  def add_rule
    count = all(".app-condition", minimum: 0).size
    click_button "Add rule"
    expect(page).to have_css(".app-condition", count: count + 1)
  end
end
