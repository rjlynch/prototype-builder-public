require "rails_helper"

# Pages expose the GOV.UK heading sizes plus an optional caption above the H1
# (https://design-system.service.gov.uk/styles/headings/). The caption matches
# the chosen heading size, and both apply whether the page renders its own
# plain H1 or an input borrows the title as its label/legend.
RSpec.describe "Page heading options", :js, type: :system do
  it "sets the heading size and caption, and applies them across the preview" do
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    fill_in "Page title", with: "Apply for a payment"
    within_preview { expect(page).to have_css("h1.govuk-heading-l", text: "Apply for a payment") }

    # Resizing the heading restyles the preview H1
    select "Extra large", from: "Heading size"
    within_preview { expect(page).to have_css("h1.govuk-heading-xl", text: "Apply for a payment") }

    # The caption sits above the heading and matches its size
    find(".app-disclosure__summary", text: "Caption").click
    fill_in "Caption", with: "Early years payments"
    within_preview do
      expect(page).to have_css("span.govuk-caption-xl", text: "Early years payments")
      expect(page).to have_css("h1.govuk-heading-xl", text: "Apply for a payment")
    end

    # Shrinking to "Small" has no caption-s, so the caption falls back to -m
    select "Medium", from: "Heading size"
    within_preview { expect(page).to have_css("span.govuk-caption-m", text: "Early years payments") }
    select "Small", from: "Heading size"
    within_preview do
      expect(page).to have_css("h1.govuk-heading-s", text: "Apply for a payment")
      expect(page).to have_css("span.govuk-caption-m", text: "Early years payments")
    end

    # The size also drives an input that borrows the title as its label
    select "Extra large", from: "Heading size"
    within_preview { expect(page).to have_css("h1.govuk-heading-xl") }
    add_component "Add text input"
    within_last_card { check "Use the page title as the label" }
    within_preview do
      expect(page).to have_css("span.govuk-caption-xl", text: "Early years payments")
      expect(page).to have_css("h1.govuk-label-wrapper label.govuk-label--xl", text: "Apply for a payment")
    end

    # Run mode renders the same caption + sizing
    visit page_path(Wizard.last.pages.first)
    expect(page).to have_css("span.govuk-caption-xl", text: "Early years payments")
    expect(page).to have_css("h1.govuk-label-wrapper label.govuk-label--xl", text: "Apply for a payment")
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def add_component(button_label)
    count = all(".app-card", minimum: 0).size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
