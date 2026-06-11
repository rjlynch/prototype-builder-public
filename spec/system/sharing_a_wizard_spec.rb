require "rails_helper"

RSpec.describe "Sharing a wizard", type: :system do
  it "lets anyone with the link walk through the journey without signing in" do
    wizard = Wizard.create!(name: "Untitled wizard")
    first = wizard.pages.create!(position: 1, title: "Claim a payment")
    first.components.create!(position: 1, kind: "paragraph", text: "Use this service to claim.")
    first.components.create!(position: 2, kind: "button", text: "Start now")
    wizard.pages.create!(position: 2, title: "Which nursery do you teach in?")

    visit wizard_path(wizard)

    expect(page).to have_css("h1", text: "Claim a payment")
    expect(page).to have_content("Use this service to claim.")
    expect(page).to have_no_field("Page title") # no builder chrome

    click_link "Start now"

    expect(page).to have_css("h1", text: "Which nursery do you teach in?")
  end

  it "shows the continue button as disabled on the last page" do
    wizard = Wizard.create!(name: "Untitled wizard")
    only = wizard.pages.create!(position: 1, title: "The only page")
    only.components.create!(position: 1, kind: "button", text: "Continue")

    visit wizard_path(wizard)

    expect(page).to have_button("Continue", disabled: true)
  end
end
