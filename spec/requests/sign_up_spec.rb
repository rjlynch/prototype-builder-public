require "rails_helper"

RSpec.describe "Sign up", type: :request do
  describe "POST /sign_up" do
    it "records a pending signup and emails a confirmation link for a new address" do
      expect {
        post sign_up_path, params: { signup: { full_name: "New Person", email_address: "new@example.com" } }
      }.to change(Signup, :count).by(1)
        .and have_enqueued_mail(AuthMailer, :activate_signup)

      signup = Signup.last
      expect(signup.email_address).to eq("new@example.com")
      expect(DestroySignupJob).to have_been_enqueued.with(signup.id)

      expect(response).to redirect_to(sign_up_path)
      follow_redirect!
      expect(response.body).to include("Check your email")
    end

    it "emails a sign-in link instead when the address is already registered" do
      team = Team.create!(name: "Personal Team")
      user = User.create!(email_address: "taken@example.com", full_name: "Taken", default_team: team)

      expect {
        post sign_up_path, params: { signup: { full_name: "Taken Again", email_address: "taken@example.com" } }
      }.to change(Signup, :count).by(0)
        .and have_enqueued_mail(AuthMailer, :sign_in_link).with(user)

      expect(response).to redirect_to(sign_up_path)
      follow_redirect!
      expect(response.body).to include("Check your email")
    end

    it "re-renders the form with errors for an invalid submission" do
      expect {
        post sign_up_path, params: { signup: { full_name: "", email_address: "not-an-email" } }
      }.not_to change(Signup, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("There is a problem")
    end
  end

  describe "POST /activation" do
    it "creates the account, signs in and lands on the dashboard" do
      signup = Signup.create!(full_name: "Fresh Face", email_address: "fresh@example.com")
      token = signup.generate_token_for(:activation)

      expect {
        post activation_path, params: { token: token }
      }.to change(User, :count).by(1)

      user = User.find_by(email_address: "fresh@example.com")
      expect(user.full_name).to eq("Fresh Face")
      expect(user.sign_in_count).to eq(1)
      expect(Signup.exists?(signup.id)).to be(false)

      expect(response).to redirect_to(wizards_path)
      get wizards_path
      expect(response).to have_http_status(:ok)
    end

    it "rejects an invalid or expired token without creating an account" do
      expect {
        post activation_path, params: { token: "nonsense" }
      }.not_to change(User, :count)

      expect(response).to redirect_to(new_sign_up_path)
    end
  end
end
