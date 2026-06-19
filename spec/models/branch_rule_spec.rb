require "rails_helper"

RSpec.describe BranchRule do
  def rule(input_name: "question-1", value: "yes", target_slug: "next-page")
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    button = page.components.create!(position: 1, kind: "button", text: "Continue")
    button.branch_rules.create!(position: 1, input_name: input_name, value: value, target_slug: target_slug)
  end

  describe "#matches?" do
    it "matches a scalar answer by parameterised equality" do
      expect(rule(value: "yes")).to be_matches("question-1" => "Yes")
      expect(rule(value: "yes")).not_to be_matches("question-1" => "no")
    end

    it "matches when the value is among a checkbox group's selected values" do
      expect(rule(value: "pip")).to be_matches("question-1" => [ "universal-credit", "pip" ])
      expect(rule(value: "pip")).not_to be_matches("question-1" => [ "universal-credit" ])
    end

    it "does not match when nothing is selected" do
      expect(rule(value: "pip")).not_to be_matches("question-1" => [ "" ])
      expect(rule(value: "pip")).not_to be_matches({})
    end

    it "never matches while incomplete" do
      expect(rule(value: "")).not_to be_matches("question-1" => "yes")
    end
  end
end
