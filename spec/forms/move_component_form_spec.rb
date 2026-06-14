require "rails_helper"

RSpec.describe MoveComponentForm do
  it "swaps a component upwards with its previous sibling" do
    page = page_with_components("paragraph", "subheading", "button")
    middle = page.components.find_by(kind: "subheading")

    form = MoveComponentForm.new(component: middle, direction: "up")

    expect(form.save).to be(true)
    expect(page.components.reload.pluck(:position, :kind))
      .to eq([ [ 1, "subheading" ], [ 2, "paragraph" ], [ 3, "button" ] ])
  end

  it "swaps a component downwards with its next sibling" do
    page = page_with_components("paragraph", "subheading", "button")
    middle = page.components.find_by(kind: "subheading")

    form = MoveComponentForm.new(component: middle, direction: "down")

    expect(form.save).to be(true)
    expect(page.components.reload.pluck(:position, :kind))
      .to eq([ [ 1, "paragraph" ], [ 2, "button" ], [ 3, "subheading" ] ])
  end

  it "swaps across gaps left by a deleted component" do
    page = page_with_components("paragraph", "subheading", "button")
    page.components.find_by(kind: "subheading").destroy! # leaves positions 1 and 3

    form = MoveComponentForm.new(component: page.components.find_by(kind: "button"), direction: "up")

    expect(form.save).to be(true)
    expect(page.components.reload.pluck(:kind)).to eq([ "button", "paragraph" ])
  end

  it "refuses to move the first component up" do
    page = page_with_components("paragraph", "button")

    form = MoveComponentForm.new(component: page.components.first, direction: "up")

    expect(form.save).to be(false)
    expect(page.components.reload.pluck(:kind)).to eq([ "paragraph", "button" ])
  end

  it "refuses to move the last component down" do
    page = page_with_components("paragraph", "button")

    form = MoveComponentForm.new(component: page.components.last, direction: "down")

    expect(form.save).to be(false)
  end

  it "refuses an unknown direction" do
    page = page_with_components("paragraph", "button")

    form = MoveComponentForm.new(component: page.components.first, direction: "sideways")

    expect(form.save).to be(false)
  end

  def page_with_components(*kinds)
    wizard = Wizard.create!(name: "Untitled wizard")
    page = wizard.pages.create!(position: 1, slug: "page-1")
    kinds.each.with_index(1) do |kind, position|
      attributes = { kind: kind, position: position }
      attributes[:name] = "question-#{position}" if Component::INPUT_KINDS.include?(kind)
      page.components.create!(attributes)
    end
    page
  end
end
