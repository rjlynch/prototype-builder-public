require "rails_helper"

RSpec.describe User do
  def build_user(**attrs)
    attrs[:default_team] = Team.create!(name: "Personal Team") unless attrs.key?(:default_team)
    User.new({ email_address: "person@example.com", full_name: "A Person" }.merge(attrs))
  end

  it "requires an email address and a full name" do
    expect(build_user(email_address: "").valid?).to be(false)
    expect(build_user(full_name: "").valid?).to be(false)
  end

  it "belongs to a default team" do
    expect(build_user(default_team: nil).valid?).to be(false)
  end

  describe "email address" do
    it "is rejected when already taken, case-insensitively" do
      team = Team.create!(name: "Personal Team")
      User.create!(email_address: "person@example.com", full_name: "First", default_team: team)

      duplicate = build_user(email_address: "PERSON@example.com", default_team: team)

      expect(duplicate.valid?).to be(false)
    end

    it "is stored downcased and stripped" do
      user = build_user(email_address: "  Person@Example.com  ")
      user.save!

      expect(user.reload.email_address).to eq("person@example.com")
    end

    it "is encrypted at rest but still queryable" do
      user = build_user(email_address: "secret@example.com")
      user.save!

      ciphertext = User.connection.select_value("SELECT email_address FROM users WHERE id = #{user.id}")
      expect(ciphertext).not_to include("secret@example.com")
      expect(User.find_by(email_address: "secret@example.com")).to eq(user)
    end
  end

  describe "#current_team" do
    it "is the user's default team" do
      team = Team.create!(name: "Personal Team")
      user = build_user(default_team: team)

      expect(user.current_team).to eq(team)
    end
  end
end
