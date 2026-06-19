require "rails_helper"

RSpec.describe ComponentForm do
  it "sets title_as_label from the checkbox value" do
    component = create_component(kind: "radios", name: "question-1")

    form = ComponentForm.from_component(component)
    form.assign_attributes(title_as_label: "1")

    expect(form.save).to be(true)
    expect(component.reload.title_as_label).to be(true)
  end

  it "clears title_as_label when the checkbox is unticked" do
    component = create_component(kind: "radios", name: "question-1", title_as_label: true)

    form = ComponentForm.from_component(component)
    form.assign_attributes(title_as_label: "0")

    expect(form.save).to be(true)
    expect(component.reload.title_as_label).to be(false)
  end

  it "refuses title_as_label when another input on the page already uses it" do
    component = create_component(kind: "radios", name: "question-1", title_as_label: true)
    rival = component.page.components.create!(position: 2, kind: "text_input", name: "question-2")

    form = ComponentForm.from_component(rival)
    form.assign_attributes(title_as_label: "1")

    expect(form.save).to be(false)
    expect(rival.reload.title_as_label).to be(false)
  end

  it "keeps title_as_label when the editor does not submit it" do
    component = create_component(kind: "radios", name: "question-1", title_as_label: true)

    form = ComponentForm.from_component(component)
    form.assign_attributes(label: "Are you eligible?")

    expect(form.save).to be(true)
    expect(component.reload.title_as_label).to be(true)
    expect(component.label).to eq("Are you eligible?")
  end

  it "saves the list style and spacing" do
    component = create_component(kind: "list", text: "One\nTwo")

    form = ComponentForm.from_component(component)
    form.assign_attributes(list_style: "number", list_spaced: "1")

    expect(form.save).to be(true)
    expect(component.reload.list_style).to eq("number")
    expect(component.list_spaced).to be(true)
  end

  it "rejects an unknown list style" do
    component = create_component(kind: "list", text: "One")

    form = ComponentForm.from_component(component)
    form.assign_attributes(list_style: "stars")

    expect(form.save).to be(false)
    expect(component.reload.list_style).to eq("none")
  end

  it "saves the button style" do
    component = create_component(kind: "button", text: "Continue")

    form = ComponentForm.from_component(component)
    form.assign_attributes(button_style: "start")

    expect(form.save).to be(true)
    expect(component.reload.button_style).to eq("start")
  end

  it "rejects an unknown button style" do
    component = create_component(kind: "button", text: "Continue")

    form = ComponentForm.from_component(component)
    form.assign_attributes(button_style: "sparkly")

    expect(form.save).to be(false)
    expect(component.reload.button_style).to eq("continue")
  end

  it "parameterises the button's target slug" do
    component = create_component(kind: "button", text: "Continue")

    form = ComponentForm.from_component(component)
    form.assign_attributes(target_slug: "Check your answers")

    expect(form.save).to be(true)
    expect(component.reload.target_slug).to eq("check-your-answers")
  end

  it "moves a component into and out of the panel" do
    component = create_component(kind: "paragraph", text: "Your reference number")

    form = ComponentForm.from_component(component)
    form.assign_attributes(in_panel: "1")
    expect(form.save).to be(true)
    expect(component.reload.in_panel).to be(true)

    form = ComponentForm.from_component(component)
    form.assign_attributes(in_panel: "0")
    expect(form.save).to be(true)
    expect(component.reload.in_panel).to be(false)
  end

  it "sets and clears the radios inline option" do
    component = create_component(kind: "radios", name: "question-1", options: "Yes\nNo")

    form = ComponentForm.from_component(component)
    form.assign_attributes(inline: "1")
    expect(form.save).to be(true)
    expect(component.reload.inline).to be(true)

    form = ComponentForm.from_component(component)
    form.assign_attributes(inline: "0")
    expect(form.save).to be(true)
    expect(component.reload.inline).to be(false)
  end

  def create_component(**attributes)
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    page.components.create!(position: 1, **attributes)
  end
end
