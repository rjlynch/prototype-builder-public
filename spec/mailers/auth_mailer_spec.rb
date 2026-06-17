require "rails_helper"

RSpec.describe AuthMailer do
  let(:team) { Team.create!(name: "Personal Team") }
  let(:user) { User.create!(email_address: "person@example.com", full_name: "A Person", default_team: team) }

  describe "#sign_in_link" do
    let(:mail) { described_class.sign_in_link(user) }

    it "is a plain-text email to the user with a working magic link" do
      expect(mail.to).to eq([ "person@example.com" ])
      expect(mail.subject).to eq("Sign in to GOV.UK Prototype Builder")
      expect(mail.content_type).to start_with("text/plain")

      token = mail.body.encoded[%r{/session/new\?token=([^\s]+)}, 1]
      expect(token).to be_present
      expect(User.find_by_token_for(:sign_in, CGI.unescape(token))).to eq(user)
    end
  end

  describe "#activate_signup" do
    let(:signup) { Signup.create!(email_address: "new@example.com", full_name: "New Person") }
    let(:mail) { described_class.activate_signup(signup) }

    it "is a plain-text email to the signup address with a working activation link" do
      expect(mail.to).to eq([ "new@example.com" ])
      expect(mail.subject).to eq("Confirm your GOV.UK Prototype Builder account")
      expect(mail.content_type).to start_with("text/plain")

      token = mail.body.encoded[%r{/activation/new\?token=([^\s]+)}, 1]
      expect(token).to be_present
      expect(Signup.find_by_token_for(:activation, CGI.unescape(token))).to eq(signup)
    end
  end

  describe "#no_account" do
    let(:mail) { described_class.no_account("stranger@example.com") }

    it "is a plain-text note to the submitted address pointing at sign up" do
      expect(mail.to).to eq([ "stranger@example.com" ])
      expect(mail.content_type).to start_with("text/plain")
      expect(mail.body.encoded).to include("no account for it yet")
      expect(mail.body.encoded).to include("/sign_up/new")
    end
  end
end
