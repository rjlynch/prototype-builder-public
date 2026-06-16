require "rails_helper"

RSpec.describe "Signing in", type: :system do
  it "requests a magic link, then signs in and lands on the dashboard" do
    user = current_user

    visit root_path
    click_link "Sign in"
    fill_in "Email address", with: user.email_address
    click_button "Send sign-in link"

    # Neutral confirmation — never says whether the email has an account.
    expect(page).to have_content("Check your email")

    # Follow the link from the email and confirm.
    sign_in(user)

    expect(page).to have_content("Your wizards")
    expect(page).to have_content("You are signed in")
  end

  it "signs out again" do
    sign_in

    click_button "Sign out"

    expect(page).to have_content("Prototype GOV.UK services without writing code")
    expect(page).to have_content("You are signed out")
  end

  it "sends signed-out visitors to the sign-in form" do
    visit wizards_path

    expect(page).to have_current_path(new_sign_in_path)
  end

  it "rejects an invalid or expired link" do
    visit new_session_path(token: "not-a-real-token")
    click_button "Sign in"

    expect(page).to have_current_path(new_sign_in_path)
    expect(page).to have_content("invalid or has expired")
  end

  it "stays neutral when the email has no account" do
    visit new_sign_in_path
    fill_in "Email address", with: "stranger@example.com"
    click_button "Send sign-in link"

    expect(page).to have_content("Check your email")
  end
end
