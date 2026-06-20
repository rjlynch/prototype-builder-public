require "rails_helper"

# A branch rule can hold several conditions, ANDed together: the rule only
# fires when every condition holds. Here a rule routes to a page only when a
# radio answer is "yes" AND a checkbox group has "pip" ticked.
RSpec.describe "AND branch rules", :js, type: :system do
  it "only branches when every condition in the rule matches" do
    sign_in
    click_button "New wizard"

    add_component "Add radio buttons"
    within_last_card do
      fill_in "Label", with: "Are you over 18?"
      fill_in "Options (one per line)", with: "yes\nno"
    end
    # Wait for the card's edits to reach the preview before the next builder
    # re-render, so the autosubmit isn't clobbered mid-flight.
    within_preview { expect(page).to have_css(".govuk-fieldset__legend", text: "Are you over 18?") }

    add_component "Add checkboxes"
    within_last_card do
      fill_in "Label", with: "Which benefits do you get?"
      fill_in "Options (one per line)", with: "Universal Credit\nPersonal Independence Payment"
    end
    within_preview { expect(page).to have_css(".govuk-fieldset__legend", text: "Which benefits do you get?") }

    add_component "Add button"

    add_rule
    # Add the second condition first: it replaces the builder pane, so filling
    # the fields afterwards avoids losing edits to a re-render.
    within_last_rule { click_button "Add condition" }
    expect(page).to have_css(".app-rule .app-condition", count: 2)

    within_last_rule do
      within_condition(0) do
        select "question-1 (Are you over 18?)", from: "When answer to"
        fill_in "Is", with: "yes"
      end
      within_condition(1) do
        select "question-2 (Which benefits do you get?)", from: "And answer to"
        fill_in "Is", with: "Personal Independence Payment"
      end
      fill_in "Go to page", with: "you-may-be-eligible"
      expect(page).to have_content("This page does not exist yet.")
    end

    # Only one condition satisfied -> the rule does not fire, journey continues
    # linearly to the next page (created blank in builder mode).
    within_preview do
      choose "yes"
      click_button "Continue"
    end
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls page-2")

    # Back to the first page; satisfy both conditions -> the rule fires.
    within_nav { first(".govuk-tabs__tab").click }
    within_preview do
      choose "yes"
      check "Personal Independence Payment"
      click_button "Continue"
    end
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls you-may-be-eligible")
  end

  it "removes an added condition" do
    sign_in
    click_button "New wizard"

    add_component "Add radio buttons"
    within_last_card do
      fill_in "Label", with: "Are you over 18?"
      fill_in "Options (one per line)", with: "yes\nno"
    end
    within_preview { expect(page).to have_css(".govuk-fieldset__legend", text: "Are you over 18?") }

    add_component "Add button"

    add_rule
    within_last_rule { click_button "Add condition" }
    expect(page).to have_css(".app-rule .app-condition", count: 2)

    within_last_rule { all(".app-condition").last.click_button("Remove condition") }
    expect(page).to have_css(".app-rule .app-condition", count: 1)
    # The sole remaining condition is removed by removing the whole rule.
    within_last_rule { expect(page).to have_no_button("Remove condition") }
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    expect(page).to have_css(".app-card", minimum: 1)
    within(all(".app-card").last, &block)
  end

  def within_last_rule(&block)
    within(all(".app-rule").last, &block)
  end

  def within_condition(index, &block)
    within(all(".app-condition")[index], &block)
  end

  def within_nav(&block)
    within("nav[aria-label='Pages in this wizard']", &block)
  end

  def add_component(button_label)
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
