require "rails_helper"

# Radio buttons can optionally display inline, per the GOV.UK pattern for a
# small number of short options.
# https://design-system.service.gov.uk/components/radios/#inline-radios
RSpec.describe "Inline radio buttons", :js, type: :system do
  it "lays the options out inline when the option is ticked" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Are you eligible?"
    add_component "Add radio buttons"
    within_last_card { fill_in "Options (one per line)", with: "Yes\nNo" }

    # Stacked by default
    within_preview { expect(page).to have_no_css(".govuk-radios--inline") }

    within_last_card { check "Display the options inline" }
    within_preview { expect(page).to have_css(".govuk-radios.govuk-radios--inline") }

    # The choice carries through to run mode
    wizard = Wizard.last
    visit page_path(wizard.pages.first)
    expect(page).to have_css(".govuk-radios.govuk-radios--inline")

    # Unticking stacks them again
    visit edit_page_path(wizard.pages.first)
    within_last_card { uncheck "Display the options inline" }
    within_preview { expect(page).to have_css(".govuk-radios") }
    within_preview { expect(page).to have_no_css(".govuk-radios--inline") }
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
