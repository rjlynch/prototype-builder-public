require "rails_helper"

# Radio buttons can optionally show an "or" text divider before the last
# option, per the GOV.UK pattern (e.g. the EYTRP gender question).
# https://design-system.service.gov.uk/components/radios/#radio-items-with-a-text-divider
RSpec.describe "Radio text divider", :js, type: :system do
  it "adds an 'or' divider before the last option when ticked" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "What is your gender?"
    add_component "Add radio buttons"
    within_last_card { fill_in "Options (one per line)", with: "Male\nFemale\nPrefer not to say" }

    # No divider by default
    within_preview { expect(page).to have_no_css(".govuk-radios__divider") }

    within_last_card { check "Show divider" }
    within_preview do
      expect(page).to have_css(".govuk-radios__divider", text: "or")
      # The divider sits immediately before the last option
      expect(page).to have_css(".govuk-radios__divider + .govuk-radios__item label", text: "Prefer not to say")
    end

    # The choice carries through to run mode
    wizard = Wizard.last
    visit page_path(wizard.pages.first)
    expect(page).to have_css(".govuk-radios__divider", text: "or")

    # Unticking removes the divider again
    visit edit_page_path(wizard.pages.first)
    within_last_card { uncheck "Show divider" }
    within_preview { expect(page).to have_no_css(".govuk-radios__divider") }
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    expect(page).to have_css(".app-card", minimum: 1)
    within(all(".app-card").last, &block)
  end

  def add_component(button_label)
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
