require "rails_helper"

# The GOV.UK panel (https://design-system.service.gov.uk/components/panel/) is a
# page-level setting: a coloured box at the top of the page holding the H1 and,
# optionally, paragraphs/subheadings marked "in the panel". "Success" is the
# shipped green confirmation panel; "Information" is a custom blue variant.
RSpec.describe "Panel component", :js, type: :system do
  it "wraps the title and chosen copy in a panel, leaving the rest outside" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Application complete"

    # Turning the panel on moves the H1 into a green confirmation panel
    choose "Success (green)"
    within_preview do
      expect(page).to have_css(".govuk-panel.govuk-panel--confirmation .govuk-panel__title", text: "Application complete")
    end

    # A paragraph marked "in the panel" renders in the panel body
    add_component "Add paragraph"
    within_last_card do
      fill_in "Paragraph text", with: "Your reference number HDJ2123F"
      check "Show inside the panel"
    end
    within_preview do
      expect(page).to have_css(".govuk-panel__body", text: "Your reference number HDJ2123F")
      # The panel body sizes its own text, so the paragraph drops govuk-body (#122)
      expect(page).to have_css(".govuk-panel__body p:not(.govuk-body)", text: "Your reference number HDJ2123F")
    end

    # A subheading left unchecked stays outside the panel
    add_component "Add subheading"
    within_last_card { fill_in "Subheading text", with: "What happens next" }
    within_preview do
      expect(page).to have_css("h2.govuk-heading-m", text: "What happens next")
      within(".govuk-panel") { expect(page).to have_no_content("What happens next") }
    end

    # Switching to the information variant restyles the panel
    choose "Information (blue)"
    within_preview do
      expect(page).to have_css(".govuk-panel.app-panel--information .govuk-panel__title", text: "Application complete")
    end

    # Run mode renders the same panel
    visit page_path(Wizard.last.pages.first)
    expect(page).to have_css(".govuk-panel.app-panel--information .govuk-panel__title", text: "Application complete")
    expect(page).to have_css(".govuk-panel__body", text: "Your reference number HDJ2123F")
  end

  it "only offers the in-panel checkbox once a panel is set" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Application complete"
    add_component "Add paragraph"
    # Page-level (not within a captured card): turning the panel on re-renders
    # the builder pane, so a held card reference would go stale. The GOV.UK
    # checkbox input is visually hidden, so assert on its label.
    expect(page).to have_no_css(".govuk-checkboxes__label", text: "Show inside the panel")

    choose "Success (green)"
    expect(page).to have_css(".govuk-checkboxes__label", text: "Show inside the panel")
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
