require "rails_helper"

RSpec.describe PageForm do
  def build_page(slug: "page-1", title: "")
    wizard = Wizard.create!(name: "Test wizard", team: personal_team)
    wizard.pages.create!(position: 1, slug: slug, title: title)
  end

  describe "slug derivation" do
    it "derives the slug from the title while the slug is the default" do
      page = build_page

      PageForm.new(page, params: { title: "What is your name" }).save

      expect(page.reload.slug).to eq("what-is-your-name")
    end

    it "keeps re-deriving as the title changes" do
      page = build_page(slug: "what-is-your", title: "What is your")

      PageForm.new(page, params: { title: "What is your name" }).save

      expect(page.reload.slug).to eq("what-is-your-name")
    end

    it "stops deriving once the slug has been customised" do
      page = build_page(slug: "custom-slug", title: "Old title")

      PageForm.new(page, params: { title: "New title" }).save

      expect(page.reload.slug).to eq("custom-slug")
      expect(page.title).to eq("New title")
    end

    it "falls back to the page-N default when the title is cleared" do
      page = build_page(slug: "old-title", title: "Old title")

      PageForm.new(page, params: { title: "" }).save

      expect(page.reload.slug).to eq("page-1")
    end
  end

  describe "customising the slug" do
    it "parameterises whatever the user types" do
      page = build_page

      PageForm.new(page, params: { slug: "What Is Your Name?" }).save

      expect(page.reload.slug).to eq("what-is-your-name")
    end

    it "uniquifies against other pages in the wizard" do
      page = build_page
      page.wizard.pages.create!(position: 2, slug: "congratulations")

      PageForm.new(page, params: { slug: "congratulations" }).save

      expect(page.reload.slug).to eq("congratulations-2")
    end

    it "re-derives from the title when cleared" do
      page = build_page(slug: "custom", title: "What is your name")

      PageForm.new(page, params: { slug: "" }).save

      expect(page.reload.slug).to eq("what-is-your-name")
    end
  end

  describe "the back link toggle" do
    it "turns the back link off and on" do
      page = build_page

      PageForm.new(page, params: { back_link: "false" }).save
      expect(page.reload.back_link).to be(false)

      PageForm.new(page, params: { back_link: "true" }).save
      expect(page.reload.back_link).to be(true)
    end

    it "leaves the back link untouched when it is not submitted" do
      page = build_page
      page.update!(back_link: false)

      PageForm.new(page, params: { title: "A new title" }).save

      expect(page.reload.back_link).to be(false)
    end
  end

  describe "the panel style" do
    it "saves a recognised panel style" do
      page = build_page

      expect(PageForm.new(page, params: { panel_style: "information" }).save).to be(true)
      expect(page.reload.panel_style).to eq("information")
    end

    it "rejects an unknown panel style" do
      page = build_page

      expect(PageForm.new(page, params: { panel_style: "rainbow" }).save).to be(false)
      expect(page.reload.panel_style).to eq("none")
    end
  end
end
