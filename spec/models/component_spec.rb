require "rails_helper"

RSpec.describe Component do
  it "allows only one input per page to use the title as its label" do
    wizard = Wizard.create!(name: "Untitled wizard")
    page = wizard.pages.create!(position: 1, slug: "page-1")
    page.components.create!(position: 1, kind: "radios", name: "question-1", title_as_label: true)

    duplicate = page.components.new(position: 2, kind: "text_input", name: "question-2", title_as_label: true)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:title_as_label]).to be_present
  end
end
