require "rails_helper"

RSpec.describe AddComponentForm do
  it "appends components with per-kind defaults" do
    wizard = Wizard.create!(name: "Test wizard")
    page = wizard.pages.create!(position: 1)

    paragraph = AddComponentForm.new(page: page, kind: "paragraph")
    button = AddComponentForm.new(page: page, kind: "button")

    expect(paragraph.save).to be(true)
    expect(button.save).to be(true)
    expect(paragraph.component).to have_attributes(position: 1, text: "")
    expect(button.component).to have_attributes(position: 2, text: "Continue")
  end

  it "rejects unknown kinds" do
    wizard = Wizard.create!(name: "Test wizard")
    page = wizard.pages.create!(position: 1)

    form = AddComponentForm.new(page: page, kind: "carousel")

    expect(form.save).to be(false)
    expect(page.components.count).to eq(0)
  end
end
