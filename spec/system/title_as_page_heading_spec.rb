require "rails_helper"

# The GOV.UK single-question pattern: an input can use the page title as its
# label (text input) or fieldset legend (radios), so the question is asked
# once as the H1 rather than twice.
RSpec.describe "Using the page title as the question", :js, type: :system do
  it "renders the title as the input's label or legend, never duplicating the H1" do
    sign_in
    click_button "New wizard"

    # --- Radios: title as the fieldset legend ---------------------------
    fill_in "Page title", with: "Are you eligible?"
    within_preview { expect(page).to have_css("h1.govuk-heading-l", text: "Are you eligible?") }
    add_component "Add radio buttons"
    within_last_card do
      fill_in "Options (one per line)", with: "Yes\nNo"
      check "Use the page title as the label"
    end

    within_preview do
      expect(page).to have_css("legend h1.govuk-fieldset__heading", text: "Are you eligible?")
      expect(page).to have_css("h1", count: 1)
      expect(page).to have_css(".govuk-radios__label", text: "Yes")
    end

    # The redundant Label field hides while the title is the label
    within_last_card { expect(page).to have_no_field("Label") }

    add_component "Add continue button"
    within_preview { click_button "Continue" }

    # --- Text input: title as the label ---------------------------------
    expect(page).to have_css(".app-disclosure__summary", text: "Slug page-2")
    fill_in "Page title", with: "What is your nursery's name?"
    within_preview { expect(page).to have_css("h1", text: "What is your nursery's name?") }
    add_component "Add text input"
    within_last_card { check "Use the page title as the label" }

    within_preview do
      expect(page).to have_css("h1.govuk-label-wrapper label.govuk-label--l", text: "What is your nursery's name?")
      expect(page).to have_css("h1", count: 1)
    end
    within_last_card { expect(page).to have_no_field("Label") }

    # While the title is taken, other inputs stop offering the option
    add_component "Add radio buttons"
    within_last_card do
      expect(page).to have_field("Label")
      expect(page).to have_no_css(".govuk-checkboxes__label", text: "Use the page title as the label")
    end

    # Unticking restores the plain H1, the Label field, and the option elsewhere
    within_text_input_card { uncheck "Use the page title as the label" }
    within_preview do
      expect(page).to have_css("h1.govuk-heading-l", text: "What is your nursery's name?")
      expect(page).to have_no_css("h1.govuk-label-wrapper")
    end
    within_text_input_card { expect(page).to have_field("Label") }
    within_last_card { expect(page).to have_css(".govuk-checkboxes__label", text: "Use the page title as the label") }

    within_text_input_card { check "Use the page title as the label" }
    within_preview { expect(page).to have_css("h1.govuk-label-wrapper") }

    # --- Run mode renders the same pattern -------------------------------
    wizard = Wizard.last
    visit page_path(wizard.pages.first)
    expect(page).to have_css("legend h1.govuk-fieldset__heading", text: "Are you eligible?")
    expect(page).to have_css("h1", count: 1)

    visit page_path(wizard.pages.second)
    expect(page).to have_css("h1.govuk-label-wrapper label.govuk-label--l", text: "What is your nursery's name?")
    expect(page).to have_css("h1", count: 1)
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def within_text_input_card(&block)
    within(find(".app-card", text: "Text input"), &block)
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
