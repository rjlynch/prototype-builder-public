require "rails_helper"

# Up/down arrows beside each editor card reorder the component within the page,
# which reorders the matching element in the live preview. The page title is
# not a component, so it has no arrows and stays first.
RSpec.describe "Reordering components", :js, type: :system do
  it "moves a card up and down, reordering the preview" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Before you start"

    add_component "Add paragraph"
    within_last_card { fill_in "Paragraph text", with: "First paragraph" }
    # Wait for the preview to reflect the save before adding the next card,
    # so the pending autosubmit isn't discarded by the builder re-render.
    within_preview { expect(page).to have_css("p", text: "First paragraph") }

    add_component "Add subheading"
    within_last_card { fill_in "Subheading text", with: "A subheading" }
    within_preview { expect(page).to have_css("h2", text: "A subheading") }

    # Preview order: paragraph immediately followed by the subheading
    within_preview { expect(page).to have_css("p + h2") }

    # Pull the subheading above the paragraph
    click_button "Move subheading up"

    within_preview do
      expect(page).to have_css("h2 + p")           # subheading now sits before the paragraph
      expect(page).to have_no_css("p + h2")
    end
    # The builder cards reordered too
    expect(card_titles).to eq([ "Subheading", "Paragraph" ])

    # And back again with the down arrow
    click_button "Move subheading down"
    within_preview { expect(page).to have_css("p + h2") }
    expect(card_titles).to eq([ "Paragraph", "Subheading" ])
  end

  it "does not offer to move past either end, and the title card has no arrows" do
    sign_in
    click_button "New wizard"

    add_component "Add paragraph"
    add_component "Add subheading"

    # The first component can't go up; the last can't go down
    expect(page).to have_no_button("Move paragraph up")
    expect(page).to have_no_button("Move subheading down")
    expect(page).to have_button("Move paragraph down")
    expect(page).to have_button("Move subheading up")

    # The page title card is not a component, so it has no reorder arrows
    within_card("Page") do
      expect(page).to have_no_button("Move page up")
      expect(page).to have_no_button("Move page down")
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def within_card(title, &block)
    within(all(".app-card").find { |card| card.has_css?(".app-card__title", text: title) }, &block)
  end

  def card_titles
    all(".app-card__title").map(&:text).reject { |title| title == "Page" }
  end

  def add_component(button_label)
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
