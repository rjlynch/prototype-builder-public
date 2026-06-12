require "rails_helper"

RSpec.describe MovePageForm do
  it "swaps the page with the one holding the target position" do
    wizard = create_wizard_with_slugs("intro", "middle", "outro")

    form = MovePageForm.new(page: wizard.pages.find_by(slug: "outro"), position: "2")

    expect(form.save).to be(true)
    expect(wizard.pages.reload.pluck(:position, :slug)).to eq([ [ 1, "intro" ], [ 2, "outro" ], [ 3, "middle" ] ])
  end

  it "refuses a position no page holds" do
    wizard = create_wizard_with_slugs("intro", "outro")

    form = MovePageForm.new(page: wizard.pages.first!, position: "5")

    expect(form.save).to be(false)
    expect(wizard.pages.reload.pluck(:position, :slug)).to eq([ [ 1, "intro" ], [ 2, "outro" ] ])
  end

  it "refuses the page's own position" do
    wizard = create_wizard_with_slugs("intro", "outro")

    form = MovePageForm.new(page: wizard.pages.first!, position: "1")

    expect(form.save).to be(false)
  end

  def create_wizard_with_slugs(*slugs)
    wizard = Wizard.create!(name: "Untitled wizard")
    slugs.each.with_index(1) { |slug, position| wizard.pages.create!(position: position, slug: slug) }
    wizard
  end
end
