require "rails_helper"

# Paragraphs and lists support a tiny markdown subset — **bold** and
# [links](target) — rendered live in the preview. A help disclosure explains
# the syntax. (No WYSIWYG editor: the plain textarea stays.)
RSpec.describe "Markdown formatting", :js, type: :system do
  it "renders bold and links from paragraph and list markdown" do
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    fill_in "Page title", with: "Eligibility"

    add_component "Add paragraph"
    within_last_card do
      expect(page).to have_css(".app-disclosure__summary", text: "Help with formatting")
      fill_in "Paragraph text",
        with: "This is **important**. See [GOV.UK](https://www.gov.uk)."
      expect(page).to have_content("Saved")
    end

    within_preview do
      expect(page).to have_css("p.govuk-body strong.govuk-\\!-font-weight-bold", text: "important")
      expect(page).to have_link("GOV.UK", href: "https://www.gov.uk")
      expect(page).to have_css("a.govuk-link", text: "GOV.UK")
    end

    add_component "Add list"
    within_last_card do
      fill_in "List items (one per line)",
        with: "Plain item\nA **bold** item\nA [linked](https://example.com) item"
      expect(page).to have_content("Saved")
    end

    within_preview do
      expect(page).to have_css("ul.govuk-list li strong", text: "bold")
      expect(page).to have_css("ul.govuk-list li a.govuk-link", text: "linked")
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
