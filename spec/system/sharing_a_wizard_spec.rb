require "rails_helper"

RSpec.describe "Sharing a wizard", type: :system do
  it "lets anyone with the link walk through the journey without signing in" do
    wizard = Wizard.create!(name: "Untitled wizard")
    first = wizard.pages.create!(position: 1, slug: "claim-a-payment", title: "Claim a payment")
    first.components.create!(position: 1, kind: "paragraph", text: "Use this service to claim.")
    first.components.create!(position: 2, kind: "button", text: "Start now")
    wizard.pages.create!(position: 2, slug: "which-nursery", title: "Which nursery do you teach in?")

    visit wizard_path(wizard)

    expect(page).to have_css("h1", text: "Claim a payment")
    expect(page).to have_content("Use this service to claim.")

    # No builder chrome: it should read like a GOV.UK service, flagged as
    # a prototype
    expect(page).to have_no_field("Page title")
    expect(page).to have_no_link("Your wizards")
    expect(page).to have_no_content("Prototype Builder")
    expect(page).to have_css(".govuk-phase-banner", text: "Prototype")

    click_button "Start now"

    expect(page).to have_css("h1", text: "Which nursery do you teach in?")
  end

  it "follows branch rules based on answers" do
    wizard = Wizard.create!(name: "Untitled wizard")
    question = wizard.pages.create!(position: 1, slug: "are-you-eligible", title: "Are you eligible?")
    question.components.create!(position: 1, kind: "radios", name: "question-1", options: "yes\nno")
    button = question.components.create!(position: 2, kind: "button", text: "Continue")
    button.branch_rules.create!(position: 1, input_name: "question-1", value: "yes", target_slug: "congratulations")
    button.branch_rules.create!(position: 2, input_name: "question-1", value: "no", target_slug: "you-are-not-eligible")
    wizard.pages.create!(position: 2, slug: "congratulations", title: "Congratulations")
    wizard.pages.create!(position: 3, slug: "you-are-not-eligible", title: "You are not eligible")

    visit wizard_path(wizard)
    choose "yes"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Congratulations")

    visit wizard_path(wizard)
    choose "no"
    click_button "Continue"

    expect(page).to have_css("h1", text: "You are not eligible")
  end

  it "shows the continue button as disabled on the last page" do
    wizard = Wizard.create!(name: "Untitled wizard")
    only = wizard.pages.create!(position: 1, slug: "the-only-page", title: "The only page")
    only.components.create!(position: 1, kind: "button", text: "Continue")

    visit wizard_path(wizard)

    expect(page).to have_button("Continue", disabled: true)
    expect(page).to have_css(".govuk-inset-text", text: "This is the end of the prototype.")
  end

  it "does not show builder empty-state hints in run mode" do
    wizard = Wizard.create!(name: "Untitled wizard")
    wizard.pages.create!(position: 1, slug: "blank-page")

    visit wizard_path(wizard)

    expect(page).to have_no_content("Your page preview appears here")
  end
end
