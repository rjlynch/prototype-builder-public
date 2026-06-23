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

  describe "#file_upload_choices" do
    it "lists only file upload inputs, labelled with their question" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      page = wizard.pages.create!(position: 1, slug: "page-1", title: "Evidence")
      page.components.create!(position: 1, kind: "file_upload", name: "question-1", label: "Upload your passport")
      page.components.create!(position: 2, kind: "text_input", name: "question-2", label: "Your name")
      page.components.create!(position: 3, kind: "file_upload", name: "question-3") # falls back to page title

      expect(wizard.file_upload_choices).to eq([
        [ "question-1 (Upload your passport)", "question-1" ],
        [ "question-3 (Evidence)", "question-3" ]
      ])
    end
  end

  describe "#answer_options" do
    it "maps fixed-answer inputs to their options, omitting free-text inputs" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      page = wizard.pages.create!(position: 1, slug: "page-1", title: "Eligibility")
      page.components.create!(position: 1, kind: "radios", name: "over-18", options: "yes\nno")
      page.components.create!(position: 2, kind: "checkboxes", name: "benefits", options: "UC\nPIP")
      page.components.create!(position: 3, kind: "text_input", name: "full-name")

      expect(wizard.answer_options).to eq(
        "over-18" => %w[ yes no ],
        "benefits" => %w[ UC PIP ]
      )
    end

    it "offers options as plain text, stripping markdown so a picked answer matches the stored value" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      page = wizard.pages.create!(position: 1, slug: "page-1", title: "Eligibility")
      page.components.create!(position: 1, kind: "checkboxes", name: "declarations",
        options: "I agree to the [terms](example.com)\nI work **full time**")

      expect(wizard.answer_options).to eq(
        "declarations" => [ "I agree to the terms", "I work full time" ]
      )
    end
  end

  describe "#page_slugs" do
    it "lists every page slug in position order" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      wizard.pages.create!(position: 2, slug: "second")
      wizard.pages.create!(position: 1, slug: "first")

      expect(wizard.page_slugs).to eq(%w[ first second ])
    end
  end
end
