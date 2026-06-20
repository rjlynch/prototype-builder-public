require "rails_helper"

RSpec.describe BranchRule do
  def rule(target_slug: "next-page", conditions: [])
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    button = page.components.create!(position: 1, kind: "button", text: "Continue")
    branch_rule = button.branch_rules.create!(position: 1, target_slug: target_slug)
    conditions.each_with_index { |c, i| branch_rule.conditions.create!(position: i + 1, **c) }
    branch_rule
  end

  describe "#complete?" do
    it "needs a target and at least one complete condition" do
      expect(rule(conditions: [ { input_name: "q-1", value: "yes" } ])).to be_complete
      expect(rule(target_slug: "", conditions: [ { input_name: "q-1", value: "yes" } ])).not_to be_complete
      expect(rule(conditions: [ { input_name: "", value: "" } ])).not_to be_complete
      expect(rule(conditions: [])).not_to be_complete
    end
  end

  describe "#matches?" do
    it "matches when its single condition matches" do
      branch_rule = rule(conditions: [ { input_name: "q-1", value: "yes" } ])

      expect(branch_rule).to be_matches("q-1" => "yes")
      expect(branch_rule).not_to be_matches("q-1" => "no")
    end

    it "ANDs its conditions: every complete condition must match" do
      branch_rule = rule(conditions: [
        { input_name: "q-1", value: "yes" },
        { input_name: "q-2", value: "pip" }
      ])

      expect(branch_rule).to be_matches("q-1" => "yes", "q-2" => [ "pip", "universal-credit" ])
      expect(branch_rule).not_to be_matches("q-1" => "yes", "q-2" => [ "universal-credit" ])
      expect(branch_rule).not_to be_matches("q-1" => "no", "q-2" => [ "pip" ])
    end

    it "ignores conditions still being filled in" do
      branch_rule = rule(conditions: [
        { input_name: "q-1", value: "yes" },
        { input_name: "", value: "" }
      ])

      expect(branch_rule).to be_matches("q-1" => "yes")
    end

    it "never matches without a target" do
      branch_rule = rule(target_slug: "", conditions: [ { input_name: "q-1", value: "yes" } ])

      expect(branch_rule).not_to be_matches("q-1" => "yes")
    end
  end
end
