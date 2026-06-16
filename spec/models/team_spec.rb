require "rails_helper"

RSpec.describe Team do
  it "requires a name" do
    expect(Team.new(name: "").valid?).to be(false)
  end

  it "has many wizards" do
    team = Team.create!(name: "Personal Team")
    wizard = team.wizards.create!(name: "A wizard")

    expect(team.wizards).to include(wizard)
  end

  it "has many users through memberships" do
    team = Team.create!(name: "Personal Team")
    user = User.create!(email_address: "member@example.com", full_name: "A Member", default_team: team)
    Membership.create!(user: user, team: team)

    expect(team.users).to eq([ user ])
  end

  it "destroys its wizards and memberships when destroyed" do
    team = Team.create!(name: "Shared Team")
    # The user's default team is elsewhere, so destroying this team only takes
    # its own wizards and the join row with it.
    user = User.create!(email_address: "member@example.com", full_name: "A Member",
                        default_team: Team.create!(name: "Personal Team"))
    Membership.create!(user: user, team: team)
    team.wizards.create!(name: "A wizard")

    team.destroy

    expect(Wizard.count).to eq(0)
    expect(Membership.count).to eq(0)
    expect(User.exists?(user.id)).to be(true)
  end
end
