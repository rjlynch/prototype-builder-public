require "rails_helper"

RSpec.describe PagePolicy do
  let(:team) { Team.create!(name: "Personal Team") }
  let(:user) { User.create!(email_address: "owner@example.com", full_name: "Owner", default_team: team) }
  let(:own_page) { team.wizards.create!(name: "Mine").pages.create!(position: 1, slug: "page-1") }
  let(:other_page) do
    Team.create!(name: "Other").wizards.create!(name: "Theirs").pages.create!(position: 1, slug: "page-1")
  end

  it "allows editing pages whose wizard is in the user's current team" do
    policy = described_class.new(user, own_page)

    expect(policy.edit?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end

  it "denies pages whose wizard belongs to another team" do
    policy = described_class.new(user, other_page)

    expect(policy.edit?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end
