require "rails_helper"

RSpec.describe ContinueForm do
  def build_wizard
    Wizard.create!(name: "Test wizard", team: personal_team)
  end

  # Each rule is { target_slug:, input_name:, value: } — the single-condition
  # shape; the condition is created as the rule's first (and only) condition.
  def add_button(page, rules: [], target_slug: "")
    button = page.components.create!(position: 99, kind: "button", text: "Continue", target_slug: target_slug)
    rules.each_with_index do |rule, index|
      branch_rule = button.branch_rules.create!(position: index + 1, target_slug: rule[:target_slug].to_s)
      branch_rule.conditions.create!(position: 1, input_name: rule[:input_name].to_s, value: rule[:value].to_s)
    end
    button
  end

  describe "linear continuation" do
    it "finds the existing next page" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      form = ContinueForm.new(page: first, button: add_button(first), answers: {}, create_missing: true)

      expect { form.save }.not_to change(wizard.pages, :count)
      expect(form.destination).to eq(second)
    end

    it "creates a blank next page in builder mode" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")

      form = ContinueForm.new(page: first, button: add_button(first), answers: {}, create_missing: true)

      expect { form.save }.to change(wizard.pages, :count).by(1)
      expect(form.destination).to have_attributes(position: 2, slug: "page-2", title: "")
    end

    it "goes nowhere in run mode at the end of the journey" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")

      form = ContinueForm.new(page: first, button: add_button(first), answers: {}, create_missing: false)

      expect { form.save }.not_to change(wizard.pages, :count)
      expect(form.destination).to be_nil
    end
  end

  describe "a button's specified slug" do
    it "goes to the button's target instead of the next page" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      wizard.pages.create!(position: 2, slug: "page-2")
      target = wizard.pages.create!(position: 3, slug: "summary")
      button = add_button(first, target_slug: "summary")

      form = ContinueForm.new(page: first, button: button, answers: {}, create_missing: false)
      form.save

      expect(form.destination).to eq(target)
    end

    it "is overridden by a matching branch rule" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      wizard.pages.create!(position: 2, slug: "summary")
      branched = wizard.pages.create!(position: 3, slug: "not-eligible")
      button = add_button(first, target_slug: "summary", rules: [
        { input_name: "question-1", value: "no", target_slug: "not-eligible" }
      ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "no" }, create_missing: false)
      form.save

      expect(form.destination).to eq(branched)
    end

    it "falls back to the button's slug when no rule matches" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      wizard.pages.create!(position: 2, slug: "page-2")
      target = wizard.pages.create!(position: 3, slug: "summary")
      button = add_button(first, target_slug: "summary", rules: [
        { input_name: "question-1", value: "no", target_slug: "not-eligible" }
      ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "yes" }, create_missing: false)
      form.save

      expect(form.destination).to eq(target)
    end

    it "creates the button's target in builder mode when it does not exist" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      button = add_button(first, target_slug: "summary")

      form = ContinueForm.new(page: first, button: button, answers: {}, create_missing: true)

      expect { form.save }.to change(wizard.pages, :count).by(1)
      expect(form.destination).to have_attributes(slug: "summary", position: 2, title: "")
    end
  end

  describe "branching" do
    it "follows the first matching rule to an existing page" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      target = wizard.pages.create!(position: 2, slug: "congratulations")
      button = add_button(first, rules: [
        { input_name: "question-1", value: "no", target_slug: "not-eligible" },
        { input_name: "question-1", value: "yes", target_slug: "congratulations" }
      ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "yes" }, create_missing: false)
      form.save

      expect(form.destination).to eq(target)
    end

    it "matches values forgivingly (Yes matches yes)" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      target = wizard.pages.create!(position: 2, slug: "congratulations")
      button = add_button(first, rules: [ { input_name: "question-1", value: "yes", target_slug: "congratulations" } ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "Yes" }, create_missing: false)
      form.save

      expect(form.destination).to eq(target)
    end

    it "can branch on answers given earlier in the wizard" do
      wizard = build_wizard
      wizard.pages.create!(position: 1, slug: "first-question")
      later = wizard.pages.create!(position: 2, slug: "later-page")
      target = wizard.pages.create!(position: 3, slug: "special-route")
      button = add_button(later, rules: [ { input_name: "earlier-answer", value: "special", target_slug: "special-route" } ])

      form = ContinueForm.new(page: later, button: button, answers: { "earlier-answer" => "special" }, create_missing: false)
      form.save

      expect(form.destination).to eq(target)
    end

    it "creates the target page in builder mode when it does not exist" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      button = add_button(first, rules: [ { input_name: "question-1", value: "yes", target_slug: "congratulations" } ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "yes" }, create_missing: true)

      expect { form.save }.to change(wizard.pages, :count).by(1)
      expect(form.destination).to have_attributes(slug: "congratulations", position: 2, title: "")
    end

    it "falls back to linear continuation when no rule matches" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")
      button = add_button(first, rules: [ { input_name: "question-1", value: "yes", target_slug: "congratulations" } ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "no" }, create_missing: false)
      form.save

      expect(form.destination).to eq(second)
    end

    it "ignores incomplete rules" do
      wizard = build_wizard
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")
      button = add_button(first, rules: [ { input_name: "question-1", value: "", target_slug: "congratulations" } ])

      form = ContinueForm.new(page: first, button: button, answers: { "question-1" => "" }, create_missing: false)
      form.save

      expect(form.destination).to eq(second)
    end
  end
end
