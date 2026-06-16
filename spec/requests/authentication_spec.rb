require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:team) { Team.create!(name: "Personal Team") }
  let!(:user) do
    User.create!(email_address: "person@example.com", full_name: "A Person", default_team: team).tap do |u|
      Membership.create!(user: u, team: team)
    end
  end

  def token_for(user) = user.generate_token_for(:sign_in)

  describe "POST /sign_in" do
    it "emails a magic link to a known address and stays neutral" do
      expect {
        post sign_in_path, params: { email_address: "person@example.com" }
      }.to have_enqueued_mail(AuthMailer, :sign_in_link).with(user)

      expect(response.body).to include("Check your email")
    end

    it "is case-insensitive about the address" do
      expect {
        post sign_in_path, params: { email_address: "PERSON@example.com" }
      }.to have_enqueued_mail(AuthMailer, :sign_in_link).with(user)
    end

    it "emails a 'no account' note for an unknown address, still neutral" do
      expect {
        post sign_in_path, params: { email_address: "stranger@example.com" }
      }.to have_enqueued_mail(AuthMailer, :no_account).with("stranger@example.com")

      expect(response.body).to include("Check your email")
    end

    it "sends nothing for a blank address" do
      expect {
        post sign_in_path, params: { email_address: "" }
      }.not_to have_enqueued_mail
    end
  end

  describe "POST /session" do
    it "signs in with a valid token and records the sign in" do
      post session_path, params: { token: token_for(user) }

      expect(response).to redirect_to(wizards_path)
      expect(user.reload.sign_in_count).to eq(1)
      expect(user.last_signed_in_at).to be_present

      # The session is live: a protected page now renders.
      get wizards_path
      expect(response).to have_http_status(:ok)
    end

    it "rejects an invalid token without signing in" do
      post session_path, params: { token: "nonsense" }

      expect(response).to redirect_to(new_sign_in_path)
      expect(user.reload.sign_in_count).to eq(0)
    end

    it "treats a token as single-use" do
      token = token_for(user)
      post session_path, params: { token: token }
      delete session_path

      # The same token no longer works once it has signed the user in.
      post session_path, params: { token: token }
      expect(response).to redirect_to(new_sign_in_path)
    end
  end

  describe "DELETE /session" do
    it "signs out" do
      post session_path, params: { token: token_for(user) }
      delete session_path

      expect(response).to redirect_to(root_path)
      get wizards_path
      expect(response).to redirect_to(new_sign_in_path)
    end
  end

  it "sends signed-out visitors from a protected page to the sign-in form" do
    get wizards_path

    expect(response).to redirect_to(new_sign_in_path)
  end
end
