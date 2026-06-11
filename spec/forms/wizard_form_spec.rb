require "rails_helper"

RSpec.describe WizardForm do
  it "creates a wizard with a blank first page" do
    form = WizardForm.new(name: "Untitled wizard")

    expect(form.save).to be(true)
    expect(form.wizard).to be_persisted
    expect(form.first_page).to have_attributes(position: 1, title: "")
  end

  it "requires a name" do
    form = WizardForm.new(name: "")

    expect(form.save).to be(false)
    expect(Wizard.count).to eq(0)
  end
end
