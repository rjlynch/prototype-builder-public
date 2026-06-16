require "rails_helper"

RSpec.describe WizardPolicy do
  let(:personal_team) { Team.create!(name: "Personal Team") }
  let(:other_team) { Team.create!(name: "Other Team") }
  let(:user) do
    User.create!(email_address: "owner@example.com", full_name: "Owner", default_team: personal_team).tap do |user|
      Membership.create!(user: user, team: personal_team)
      Membership.create!(user: user, team: other_team)
    end
  end
  let(:own_wizard) { personal_team.wizards.create!(name: "Mine") }
  # In a team the user belongs to but isn't currently "in".
  let(:other_team_wizard) { other_team.wizards.create!(name: "Also mine") }
  let(:foreign_wizard) { Team.create!(name: "Someone else").wizards.create!(name: "Theirs") }

  describe "#edit? / #update?" do
    it "allows wizards in any team the user is a member of" do
      expect(described_class.new(user, own_wizard).edit?).to be(true)
      expect(described_class.new(user, other_team_wizard).edit?).to be(true)
      expect(described_class.new(user, own_wizard).update?).to be(true)
    end

    it "denies wizards in a team the user does not belong to" do
      expect(described_class.new(user, foreign_wizard).edit?).to be(false)
      expect(described_class.new(user, foreign_wizard).update?).to be(false)
    end

    it "denies when there is no current user" do
      expect(described_class.new(nil, own_wizard).edit?).to be(false)
    end
  end

  describe "#create?" do
    it "is allowed for a signed-in user" do
      expect(described_class.new(user, Wizard).create?).to be(true)
    end

    it "is denied without a current user" do
      expect(described_class.new(nil, Wizard).create?).to be(false)
    end
  end

  describe WizardPolicy::Scope do
    it "returns wizards across every team the user belongs to" do
      mine = own_wizard
      also_mine = other_team_wizard
      foreign_wizard # belongs to a team the user is not on

      resolved = described_class.new(user, Wizard).resolve

      expect(resolved).to contain_exactly(mine, also_mine)
    end

    it "returns nothing without a current user" do
      own_wizard
      expect(described_class.new(nil, Wizard).resolve).to be_empty
    end
  end
end
