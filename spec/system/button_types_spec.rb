require "rails_helper"

# Buttons offer the GOV.UK button variants: continue (the default), secondary,
# inverse, start, and warning. Picking a type swaps the modifier class in the
# live preview; the start button also gains the arrow icon.
RSpec.describe "Button types", :js, type: :system do
  it "switches between button types with a live preview" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Before you start"
    add_component "Add button"

    within_last_card do
      fill_in "Button text", with: "Start now"
      expect(page).to have_content("Saved")
    end

    # Defaults to the plain continue button (no modifier class)
    within_preview do
      expect(page).to have_css("button.govuk-button", text: "Start now")
      expect(page).to have_no_css("button.govuk-button--secondary")
    end

    within_last_card { choose "Secondary" }
    within_preview do
      expect(page).to have_css("button.govuk-button.govuk-button--secondary", text: "Start now")
    end

    within_last_card { choose "Start" }
    within_preview do
      expect(page).to have_css("button.govuk-button.govuk-button--start", text: "Start now")
      expect(page).to have_css("button .govuk-button__start-icon")
    end

    within_last_card { choose "Warning" }
    within_preview do
      expect(page).to have_css("button.govuk-button.govuk-button--warning", text: "Start now")
      expect(page).to have_no_css("button .govuk-button__start-icon")
    end
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
