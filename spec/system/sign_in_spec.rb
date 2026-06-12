require "rails_helper"

RSpec.describe "Signing in", type: :system do
  it "signs in from the landing page and lands on the dashboard" do
    visit root_path

    expect(page).to have_content("Prototype GOV.UK services without writing code")

    click_button "Sign in"

    expect(page).to have_content("Your wizards")
    expect(page).to have_content("You have not created any wizards yet. Select New wizard to start building one.")
  end

  it "signs out again" do
    visit root_path
    click_button "Sign in"

    click_button "Sign out"

    expect(page).to have_content("Prototype GOV.UK services without writing code")
  end

  it "redirects signed-out visitors away from the dashboard" do
    visit wizards_path

    expect(page).to have_current_path(root_path)
  end
end
