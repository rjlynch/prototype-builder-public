require "rails_helper"

RSpec.describe Page, type: :model do
  describe "validations" do
    it "requires a unique position within its wizard" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      wizard.pages.create!(position: 1, slug: "page-1")
      duplicate = wizard.pages.build(position: 1, slug: "other")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:position]).to be_present
    end

    it "requires a positive integer position" do
      page = Wizard.create!(name: "Test wizard", team: personal_team).pages.build(position: 0, slug: "page-0")

      expect(page).not_to be_valid
    end
  end

  describe "#next" do
    it "returns the page at the following position, or nil" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      expect(first.next).to eq(second)
      expect(second.next).to be_nil
    end
  end

  describe "#previous" do
    it "returns the page at the preceding position, or nil" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      expect(second.previous).to eq(first)
      expect(first.previous).to be_nil
    end
  end

  describe "#show_back_link?" do
    it "is true by default for a page that has a previous one" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      expect(second.show_back_link?).to be(true)
    end

    it "is false for the first page, which has nowhere to go back to" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      first = wizard.pages.create!(position: 1, slug: "page-1")
      wizard.pages.create!(position: 2, slug: "page-2")

      expect(first.show_back_link?).to be(false)
    end

    it "is false when the back link is turned off for the page" do
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2", back_link: false)

      expect(second.show_back_link?).to be(false)
    end
  end

  describe "panels" do
    def page_with(panel_style:)
      wizard = Wizard.create!(name: "Test wizard", team: personal_team)
      wizard.pages.create!(position: 1, slug: "page-1", title: "Done", panel_style: panel_style)
    end

    it "knows when a panel is set" do
      expect(page_with(panel_style: "none")).not_to be_panel
      expect(page_with(panel_style: "success")).to be_panel
      expect(page_with(panel_style: "information")).to be_panel
    end

    it "maps the style to the right wrapper classes" do
      expect(page_with(panel_style: "success").panel_class).to eq("govuk-panel govuk-panel--confirmation")
      expect(page_with(panel_style: "information").panel_class).to eq("govuk-panel app-panel--information")
    end

    it "does not let an input claim the title while a panel owns it" do
      page = page_with(panel_style: "success")
      page.components.create!(position: 1, kind: "radios", name: "question-1", title_as_label: true)

      expect(page.heading_component).to be_nil
    end

    it "collects in-panel paragraphs and subheadings, ignoring other kinds" do
      page = page_with(panel_style: "success")
      para = page.components.create!(position: 1, kind: "paragraph", text: "Ref ABC", in_panel: true)
      sub = page.components.create!(position: 2, kind: "subheading", text: "Next", in_panel: true)
      page.components.create!(position: 3, kind: "paragraph", text: "Outside", in_panel: false)
      page.components.create!(position: 4, kind: "button", text: "Continue", in_panel: true)

      expect(page.panel_body_components).to eq([ para, sub ])
    end

    it "has no panel body components when no panel is set" do
      page = page_with(panel_style: "none")
      page.components.create!(position: 1, kind: "paragraph", text: "Ref ABC", in_panel: true)

      expect(page.panel_body_components).to eq([])
    end

    it "renders everything except the in-panel components in the body" do
      page = page_with(panel_style: "success")
      panelled = page.components.create!(position: 1, kind: "paragraph", text: "Ref ABC", in_panel: true)
      outside = page.components.create!(position: 2, kind: "paragraph", text: "Outside", in_panel: false)
      button = page.components.create!(position: 3, kind: "button", text: "Continue")

      expect(page.body_components).to eq([ outside, button ])
      expect(page.body_components).not_to include(panelled)
    end

    it "treats every component as body content when no panel is set" do
      page = page_with(panel_style: "none")
      para = page.components.create!(position: 1, kind: "paragraph", text: "Ref ABC", in_panel: true)

      expect(page.body_components).to eq([ para ])
    end
  end
end
