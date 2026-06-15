require "rails_helper"

RSpec.describe Page, type: :model do
  describe "validations" do
    it "requires a unique position within its wizard" do
      wizard = Wizard.create!(name: "Test wizard")
      wizard.pages.create!(position: 1, slug: "page-1")
      duplicate = wizard.pages.build(position: 1, slug: "other")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:position]).to be_present
    end

    it "requires a positive integer position" do
      page = Wizard.create!(name: "Test wizard").pages.build(position: 0, slug: "page-0")

      expect(page).not_to be_valid
    end
  end

  describe "#next" do
    it "returns the page at the following position, or nil" do
      wizard = Wizard.create!(name: "Test wizard")
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      expect(first.next).to eq(second)
      expect(second.next).to be_nil
    end
  end

  describe "#previous" do
    it "returns the page at the preceding position, or nil" do
      wizard = Wizard.create!(name: "Test wizard")
      first = wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      expect(second.previous).to eq(first)
      expect(first.previous).to be_nil
    end
  end

  describe "#show_back_link?" do
    it "is true by default for a page that has a previous one" do
      wizard = Wizard.create!(name: "Test wizard")
      wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2")

      expect(second.show_back_link?).to be(true)
    end

    it "is false for the first page, which has nowhere to go back to" do
      wizard = Wizard.create!(name: "Test wizard")
      first = wizard.pages.create!(position: 1, slug: "page-1")
      wizard.pages.create!(position: 2, slug: "page-2")

      expect(first.show_back_link?).to be(false)
    end

    it "is false when the back link is turned off for the page" do
      wizard = Wizard.create!(name: "Test wizard")
      wizard.pages.create!(position: 1, slug: "page-1")
      second = wizard.pages.create!(position: 2, slug: "page-2", back_link: false)

      expect(second.show_back_link?).to be(false)
    end
  end
end
