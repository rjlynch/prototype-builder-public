require "rails_helper"

RSpec.describe ComponentPolicy do
  let(:team) { Team.create!(name: "Personal Team") }
  let(:user) do
    User.create!(email_address: "owner@example.com", full_name: "Owner", default_team: team).tap do |user|
      Membership.create!(user: user, team: team)
    end
  end

  def component_in(team)
    page = team.wizards.create!(name: "W").pages.create!(position: 1, slug: "page-1")
    page.components.create!(position: 1, kind: "paragraph", text: "Hi")
  end

  let(:own_component) { component_in(team) }
  let(:foreign_component) { component_in(Team.create!(name: "Other")) }

  it "allows editing components whose wizard is in a team the user belongs to" do
    policy = described_class.new(user, own_component)

    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end

  it "denies components whose wizard belongs to a team the user is not on" do
    policy = described_class.new(user, foreign_component)

    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end
