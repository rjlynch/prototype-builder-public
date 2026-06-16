require "rails_helper"

# Lists are their own editor component (separate from paragraphs), offering the
# GOV.UK list styles: no decoration, bullets, numbers, and extra spacing.
RSpec.describe "List components", :js, type: :system do
  it "adds a list and switches between styles with a live preview" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Before you start"
    add_component "Add list"

    within_last_card do
      fill_in "List items (one per line)", with: "First thing\nSecond thing"
      expect(page).to have_content("Saved")
    end

    # Defaults to an undecorated list
    within_preview do
      expect(page).to have_css("ul.govuk-list", text: "First thing")
      expect(page).to have_css("ul.govuk-list li", text: "Second thing")
      expect(page).to have_no_css("ul.govuk-list--bullet")
    end

    within_last_card { choose "Bullets" }
    within_preview do
      expect(page).to have_css("ul.govuk-list.govuk-list--bullet li", text: "First thing")
    end

    within_last_card { choose "Numbers" }
    within_preview do
      expect(page).to have_css("ol.govuk-list.govuk-list--number li", text: "First thing")
      expect(page).to have_no_css("ul.govuk-list")
    end

    within_last_card { check "Add extra spacing between items" }
    within_preview do
      expect(page).to have_css("ol.govuk-list--number.govuk-list--spaced")
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
