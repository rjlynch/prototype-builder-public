require "rails_helper"

RSpec.describe WizardPolicy do
  let(:team) { Team.create!(name: "Personal Team") }
  let(:user) { User.create!(email_address: "owner@example.com", full_name: "Owner", default_team: team) }
  let(:own_wizard) { team.wizards.create!(name: "Mine") }
  let(:other_wizard) { Team.create!(name: "Other").wizards.create!(name: "Theirs") }

  describe "#edit? / #update?" do
    it "allows wizards in the user's current team" do
      policy = described_class.new(user, own_wizard)

      expect(policy.edit?).to be(true)
      expect(policy.update?).to be(true)
    end

    it "denies wizards in another team" do
      policy = described_class.new(user, other_wizard)

      expect(policy.edit?).to be(false)
      expect(policy.update?).to be(false)
    end

    it "denies when there is no current user" do
      expect(described_class.new(nil, own_wizard).edit?).to be(false)
    end
  end

  describe "#create?" do
    it "is allowed when the user has a current team" do
      expect(described_class.new(user, Wizard).create?).to be(true)
    end

    it "is denied without a current user" do
      expect(described_class.new(nil, Wizard).create?).to be(false)
    end
  end

  describe WizardPolicy::Scope do
    it "returns only wizards in the user's current team" do
      mine = own_wizard
      other_wizard # create a wizard in another team

      resolved = described_class.new(user, Wizard).resolve

      expect(resolved).to contain_exactly(mine)
    end

    it "returns nothing without a current user" do
      own_wizard
      expect(described_class.new(nil, Wizard).resolve).to be_empty
    end
  end
end
