require "rails_helper"

RSpec.describe "Signing up", type: :system do
  # Follow the confirmation link the way the email would, then confirm.
  def confirm(signup)
    visit new_activation_path(token: signup.generate_token_for(:activation))
    click_button "Create account"
  end

  it "registers, confirms from the email link, and lands on the dashboard" do
    visit root_path
    click_link "Create an account"

    fill_in "Full name", with: "Ada Lovelace"
    fill_in "Email address", with: "ada@example.com"
    click_button "Create account"

    # Neutral confirmation — never says whether the address could register.
    expect(page).to have_content("Check your email")

    confirm(Signup.find_by(email_address: "ada@example.com"))

    expect(page).to have_content("Your wizards")
    expect(page).to have_content("Your account is ready")

    user = User.find_by(email_address: "ada@example.com")
    expect(user.full_name).to eq("Ada Lovelace")
    expect(user.current_team.name).to eq("Personal Team")
  end

  it "shows field errors for an invalid submission" do
    visit new_sign_up_path
    fill_in "Full name", with: ""
    fill_in "Email address", with: "nope"
    click_button "Create account"

    expect(page).to have_content("There is a problem")
    expect(page).to have_field("Full name")
  end

  it "stays neutral and does not create a duplicate when already registered" do
    existing = current_user # the helper creates a real user

    visit new_sign_up_path
    fill_in "Full name", with: "Someone Else"
    fill_in "Email address", with: existing.email_address
    click_button "Create account"

    expect(page).to have_content("Check your email")
    expect(Signup.count).to eq(0)
  end

  it "rejects an invalid or expired confirmation link" do
    visit new_activation_path(token: "not-a-real-token")
    click_button "Create account"

    expect(page).to have_current_path(new_sign_up_path)
    expect(page).to have_content("invalid or has expired")
  end
end
