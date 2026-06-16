require "rails_helper"

RSpec.describe Membership do
  it "is unique per user and team" do
    team = Team.create!(name: "Personal Team")
    user = User.create!(email_address: "member@example.com", full_name: "A Member", default_team: team)
    Membership.create!(user: user, team: team)

    duplicate = Membership.new(user: user, team: team)

    expect(duplicate.valid?).to be(false)
  end

  it "lets a user belong to more than one team" do
    personal = Team.create!(name: "Personal Team")
    shared = Team.create!(name: "Shared Team")
    user = User.create!(email_address: "member@example.com", full_name: "A Member", default_team: personal)

    Membership.create!(user: user, team: personal)
    Membership.create!(user: user, team: shared)

    expect(user.teams).to contain_exactly(personal, shared)
  end
end
