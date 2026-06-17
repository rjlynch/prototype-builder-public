require "rails_helper"

RSpec.describe Component do
  it "allows only one input per page to use the title as its label" do
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    page.components.create!(position: 1, kind: "radios", name: "question-1", title_as_label: true)

    duplicate = page.components.new(position: 2, kind: "text_input", name: "question-2", title_as_label: true)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:title_as_label]).to be_present
  end

  it "splits list text into stripped, non-blank items" do
    component = Component.new(text: "  First  \n\nSecond\n")

    expect(component.list_items).to eq([ "First", "Second" ])
  end

  it "is ordered only for the number style" do
    expect(Component.new(list_style: "number")).to be_list_ordered
    expect(Component.new(list_style: "bullet")).not_to be_list_ordered
    expect(Component.new(list_style: "none")).not_to be_list_ordered
  end

  it "gives a GOV.UK modifier class for every button style but the default" do
    expect(Component.new(button_style: "continue").button_modifier_class).to be_nil
    expect(Component.new(button_style: "secondary").button_modifier_class).to eq("govuk-button--secondary")
    expect(Component.new(button_style: "warning").button_modifier_class).to eq("govuk-button--warning")
  end

  it "knows the start button (which renders the arrow icon)" do
    expect(Component.new(button_style: "start")).to be_start_button
    expect(Component.new(button_style: "continue")).not_to be_start_button
  end
end
