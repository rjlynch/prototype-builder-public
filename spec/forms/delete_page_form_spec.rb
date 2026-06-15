require "rails_helper"

RSpec.describe DeletePageForm do
  it "deletes the page and renumbers the rest contiguously" do
    wizard = create_wizard_with_slugs("intro", "middle", "outro")

    form = DeletePageForm.new(wizard.pages.find_by(slug: "middle"))

    expect(form.save).to be(true)
    expect(wizard.pages.reload.pluck(:position, :slug)).to eq([ [ 1, "intro" ], [ 2, "outro" ] ])
  end

  it "deletes the page's components with it" do
    wizard = create_wizard_with_slugs("intro", "outro")
    intro = wizard.pages.find_by(slug: "intro")
    intro.components.create!(position: 1, kind: "paragraph", text: "Hello")

    form = DeletePageForm.new(intro)

    expect(form.save).to be(true)
    expect(Component.count).to eq(0)
  end

  it "sends the user to the previous page" do
    wizard = create_wizard_with_slugs("intro", "middle", "outro")

    form = DeletePageForm.new(wizard.pages.find_by(slug: "middle"))
    form.save

    expect(form.destination.slug).to eq("intro")
  end

  it "sends the user to the new first page when the first page is deleted" do
    wizard = create_wizard_with_slugs("intro", "middle", "outro")

    form = DeletePageForm.new(wizard.pages.find_by(slug: "intro"))
    form.save

    expect(form.destination.slug).to eq("middle")
    expect(form.destination.reload.position).to eq(1)
  end

  it "refuses to delete a wizard's only page" do
    wizard = create_wizard_with_slugs("intro")

    form = DeletePageForm.new(wizard.pages.first!)

    expect(form.save).to be(false)
    expect(wizard.pages.reload.count).to eq(1)
  end

  def create_wizard_with_slugs(*slugs)
    wizard = Wizard.create!(name: "Untitled wizard")
    slugs.each.with_index(1) { |slug, position| wizard.pages.create!(position: position, slug: slug) }
    wizard
  end
end
