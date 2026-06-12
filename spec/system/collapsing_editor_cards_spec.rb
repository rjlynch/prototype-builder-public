require "rails_helper"

# Editor cards are collapsible <details> elements whose open/closed state is
# remembered (per tab) across the full builder-pane re-renders that adding
# or removing a component triggers.
RSpec.describe "Collapsing editor cards", :js, type: :system do
  it "remembers collapsed cards across builder re-renders and reloads" do
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    add_component "Add paragraph"
    within_last_card { fill_in "Paragraph text", with: "Some intro copy" }
    within_preview { expect(page).to have_css("p", text: "Some intro copy") }

    # Collapse the paragraph card; its summary still identifies it
    find(".app-card > summary").click
    expect(page).to have_css(".app-card:not([open])", count: 1)
    within(".app-card:not([open])") do
      expect(page).to have_css(".app-card__title", text: "Paragraph")
      expect(page).to have_css(".app-card__snippet", text: "Some intro copy")
    end

    # Adding a component replaces the whole builder pane: the collapsed card
    # stays collapsed, the new card arrives expanded
    add_component "Add continue button"
    expect(page).to have_css(".app-card:not([open]) .app-card__title", text: "Paragraph")
    expect(page).to have_css(".app-card[open] .app-card__title", text: "Continue button")

    # A full page load restores the state too
    visit current_path
    expect(page).to have_css(".app-card:not([open]) .app-card__title", text: "Paragraph")
    expect(page).to have_css(".app-card[open] .app-card__title", text: "Continue button")

    # Expanding again is remembered across the next re-render
    find(".app-card:not([open]) > summary").click
    expect(page).to have_css(".app-card[open]", count: 2)
    add_component "Add paragraph"
    expect(page).to have_css(".app-card[open]", count: 3)
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
