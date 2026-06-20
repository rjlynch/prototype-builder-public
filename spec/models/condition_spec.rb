require "rails_helper"

RSpec.describe Condition do
  def condition(input_name: "question-1", value: "yes")
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    button = page.components.create!(position: 1, kind: "button", text: "Continue")
    rule = button.branch_rules.create!(position: 1, target_slug: "next")
    rule.conditions.create!(position: 1, input_name: input_name, value: value)
  end

  describe "#complete?" do
    it "needs both an input and a value" do
      expect(condition(input_name: "q-1", value: "yes")).to be_complete
      expect(condition(input_name: "q-1", value: "")).not_to be_complete
      expect(condition(input_name: "", value: "yes")).not_to be_complete
    end
  end

  describe "#matches?" do
    it "matches a scalar answer by parameterised equality" do
      expect(condition(value: "yes")).to be_matches("question-1" => "Yes")
      expect(condition(value: "yes")).not_to be_matches("question-1" => "no")
    end

    it "matches when the value is among a checkbox group's selected values" do
      expect(condition(value: "pip")).to be_matches("question-1" => [ "universal-credit", "pip" ])
      expect(condition(value: "pip")).not_to be_matches("question-1" => [ "universal-credit" ])
    end

    it "does not match when nothing is selected" do
      expect(condition(value: "pip")).not_to be_matches("question-1" => [ "" ])
      expect(condition(value: "pip")).not_to be_matches({})
    end

    it "never matches while incomplete" do
      expect(condition(value: "")).not_to be_matches("question-1" => "yes")
    end
  end
end
