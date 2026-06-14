require "rails_helper"

RSpec.describe InsertPageForm do
  it "inserts a blank page after the given one and shifts the rest down" do
    wizard = create_wizard_with_slugs("intro", "middle", "outro")

    form = InsertPageForm.new(page: wizard.pages.find_by(slug: "intro"))

    expect(form.save).to be(true)
    expect(form.new_page.position).to eq(2)
    expect(wizard.pages.reload.pluck(:position, :slug)).to eq(
      [ [ 1, "intro" ], [ 2, form.new_page.slug ], [ 3, "middle" ], [ 4, "outro" ] ]
    )
  end

  it "appends after the last page" do
    wizard = create_wizard_with_slugs("intro", "outro")

    form = InsertPageForm.new(page: wizard.pages.find_by(slug: "outro"))

    expect(form.save).to be(true)
    expect(wizard.pages.reload.pluck(:position).max).to eq(3)
    expect(form.new_page.position).to eq(3)
  end

  it "gives the new page a slug that is unique within the wizard" do
    wizard = create_wizard_with_slugs("intro", "page-2")

    form = InsertPageForm.new(page: wizard.pages.find_by(slug: "intro"))

    expect(form.save).to be(true)
    expect(form.new_page.slug).not_to eq("page-2")
    expect(wizard.pages.reload.pluck(:slug).uniq.size).to eq(3)
  end

  def create_wizard_with_slugs(*slugs)
    wizard = Wizard.create!(name: "Untitled wizard")
    slugs.each.with_index(1) { |slug, position| wizard.pages.create!(position: position, slug: slug) }
    wizard
  end
end
