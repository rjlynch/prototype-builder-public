require "rails_helper"

RSpec.describe Signup do
  def build_signup(**attrs)
    Signup.new({ email_address: "new@example.com", full_name: "New Person" }.merge(attrs))
  end

  it "requires a full name and a well-formed email address" do
    expect(build_signup(full_name: "").valid?).to be(false)
    expect(build_signup(email_address: "").valid?).to be(false)
    expect(build_signup(email_address: "not-an-email").valid?).to be(false)
    expect(build_signup.valid?).to be(true)
  end

  it "stores the email address encrypted, downcased and stripped" do
    signup = build_signup(email_address: "  New@Example.com  ")
    signup.save!

    expect(signup.reload.email_address).to eq("new@example.com")
    ciphertext = Signup.connection.select_value("SELECT email_address FROM signups WHERE id = #{signup.id}")
    expect(ciphertext).not_to include("new@example.com")
  end

  describe "activation token" do
    it "resolves back to the signup until it is consumed or expires" do
      signup = build_signup.tap(&:save!)
      token = signup.generate_token_for(:activation)

      expect(Signup.find_by_token_for(:activation, token)).to eq(signup)

      signup.destroy
      expect(Signup.find_by_token_for(:activation, token)).to be_nil
    end

    it "expires after 15 minutes" do
      signup = build_signup.tap(&:save!)
      token = signup.generate_token_for(:activation)

      travel(16.minutes) do
        expect(Signup.find_by_token_for(:activation, token)).to be_nil
      end
    end
  end

  describe "#activate!" do
    it "creates a Personal Team, the user and their membership, then consumes itself" do
      signup = build_signup(email_address: "fresh@example.com", full_name: "Fresh Face").tap(&:save!)

      user = signup.activate!

      expect(user.email_address).to eq("fresh@example.com")
      expect(user.full_name).to eq("Fresh Face")
      expect(user.default_team.name).to eq("Personal Team")
      expect(user.teams).to eq([ user.default_team ])
      expect(Signup.exists?(signup.id)).to be(false)
    end

    it "returns the existing user without creating a duplicate when already registered" do
      team = Team.create!(name: "Personal Team")
      existing = User.create!(email_address: "taken@example.com", full_name: "Taken", default_team: team)
      signup = build_signup(email_address: "taken@example.com").tap(&:save!)

      expect { @user = signup.activate! }.not_to change(User, :count)
      expect(@user).to eq(existing)
      expect(Signup.exists?(signup.id)).to be(false)
    end
  end
end
