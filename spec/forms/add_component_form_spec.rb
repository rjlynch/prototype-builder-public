require "rails_helper"

RSpec.describe AddComponentForm do
  it "appends components with per-kind defaults" do
    wizard = Wizard.create!(name: "Test wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")

    paragraph = AddComponentForm.new(page: page, kind: "paragraph")
    subheading = AddComponentForm.new(page: page, kind: "subheading")
    checkboxes = AddComponentForm.new(page: page, kind: "checkboxes")
    button = AddComponentForm.new(page: page, kind: "button")

    expect(paragraph.save).to be(true)
    expect(subheading.save).to be(true)
    expect(checkboxes.save).to be(true)
    expect(button.save).to be(true)
    expect(paragraph.component).to have_attributes(position: 1, text: "")
    expect(subheading.component).to have_attributes(position: 2, text: "")
    expect(checkboxes.component).to have_attributes(position: 3, kind: "checkboxes", options: "", name: "question-1")
    expect(button.component).to have_attributes(position: 4, text: "Continue")
  end

  it "generates input names unique within the wizard" do
    wizard = Wizard.create!(name: "Test wizard", team: personal_team)
    first_page = wizard.pages.create!(position: 1, slug: "page-1")
    second_page = wizard.pages.create!(position: 2, slug: "page-2")

    text_input = AddComponentForm.new(page: first_page, kind: "text_input")
    radios = AddComponentForm.new(page: second_page, kind: "radios")

    expect(text_input.save).to be(true)
    expect(radios.save).to be(true)
    expect(text_input.component.name).to eq("question-1")
    expect(radios.component.name).to eq("question-2")
  end

  it "skips over names the user has already taken" do
    wizard = Wizard.create!(name: "Test wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    page.components.create!(position: 1, kind: "text_input", name: "question-1")

    form = AddComponentForm.new(page: page, kind: "radios")

    expect(form.save).to be(true)
    expect(form.component.name).to eq("question-2")
  end

  it "rejects unknown kinds" do
    wizard = Wizard.create!(name: "Test wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")

    form = AddComponentForm.new(page: page, kind: "carousel")

    expect(form.save).to be(false)
    expect(page.components.count).to eq(0)
  end
end
