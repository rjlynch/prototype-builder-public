require "rails_helper"

RSpec.describe Wizard do
  describe "#input_choices" do
    it "labels each answer key with its question" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      first_page = wizard.pages.create!(position: 1, slug: "page-1", title: "Are you eligible?")
      second_page = wizard.pages.create!(position: 2, slug: "page-2", title: "")
      first_page.components.create!(position: 1, kind: "radios", name: "question-1") # falls back to the page title
      first_page.components.create!(position: 2, kind: "text_input", name: "question-2", label: "Enter your name")
      second_page.components.create!(position: 1, kind: "text_input", name: "question-3") # nothing to fall back to

      expect(wizard.input_choices).to eq([
        [ "question-1 (Are you eligible?)", "question-1" ],
        [ "question-2 (Enter your name)", "question-2" ],
        [ "question-3", "question-3" ]
      ])
    end
  end
end
