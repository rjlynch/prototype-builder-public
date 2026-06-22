require "rails_helper"

# The `check_answers` component plays earlier answers back as a GOV.UK summary
# list for review. The builder picks which questions to show from a checklist;
# run mode renders the answers with Change links that return to the summary
# after the answer is updated. Issue #116.
RSpec.describe "Check answers components", :js, type: :system do
  # A three-page journey: ask a name, ask a colour, then summarise both.
  def build_journey
    wizard = Wizard.create!(name: "About you", team: current_user.default_team)
    name = wizard.pages.create!(position: 1, slug: "your-name", title: "What is your name?")
    colour = wizard.pages.create!(position: 2, slug: "your-colour", title: "Pick a colour")
    summary = wizard.pages.create!(position: 3, slug: "check-answers", title: "Check your answers")

    name.components.create!(position: 1, kind: "text_input", name: "question-1", label: "Your name")
    name.components.create!(position: 2, kind: "button", text: "Continue")
    colour.components.create!(position: 1, kind: "radios", name: "question-2", label: "Favourite colour", options: "Red\nBlue")
    colour.components.create!(position: 2, kind: "button", text: "Continue")
    summary.components.create!(position: 1, kind: "check_answers", text: "question-1\nquestion-2")
    summary.components.create!(position: 2, kind: "button", text: "Accept and send")
    [ name, colour, summary ]
  end

  it "summarises earlier answers and lets the user change one and return" do
    sign_in
    name, = build_journey

    visit page_path(name)
    fill_in "Your name", with: "Ada"
    click_button "Continue"

    choose "Blue"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Check your answers")
    within(".govuk-summary-list") do
      expect(page).to have_content("Your name")
      expect(page).to have_content("Ada")
      expect(page).to have_content("Favourite colour")
      expect(page).to have_content("Blue")
    end

    # Change the name, then Continue returns to the summary with the new value.
    # The row's question scopes which "Change" link (the rest is visually hidden).
    within(".govuk-summary-list__row", text: "Your name") { click_link "Change" }
    expect(page).to have_css("h1", text: "What is your name?")
    fill_in "Your name", with: "Grace"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Check your answers")
    expect(page).to have_content("Grace")
  end

  it "offers the wizard's questions in the builder and previews the structure" do
    sign_in
    name, = build_journey

    visit edit_page_path(name.wizard.pages.find_by(slug: "check-answers"))

    # GOV.UK visually hides the native checkboxes, so match them with visible: :all.
    within(find(".app-card", text: "Questions to show")) do
      expect(page).to have_field("Your name", checked: true, visible: :all)
      expect(page).to have_field("Favourite colour", checked: true, visible: :all)
    end

    within_preview do
      expect(page).to have_css(".govuk-summary-list__key", text: "Your name")
      expect(page).to have_content("Answer to “question-1”")
      # In the builder the Change link goes to the question's editor, not its
      # public page.
      within(".govuk-summary-list__row", text: "Your name") do
        expect(page).to have_link("Change", href: edit_page_path(name))
      end
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end
end
