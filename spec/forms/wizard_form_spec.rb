require "rails_helper"

RSpec.describe WizardForm do
  it "creates a wizard with a blank first page in the given team" do
    form = WizardForm.new(name: "Untitled wizard", team: personal_team)

    expect(form.save).to be(true)
    expect(form.wizard).to be_persisted
    expect(form.wizard.team).to eq(personal_team)
    expect(form.first_page).to have_attributes(position: 1, title: "", slug: "page-1")
  end

  it "requires a name" do
    form = WizardForm.new(name: "", team: personal_team)

    expect(form.save).to be(false)
    expect(Wizard.count).to eq(0)
  end

  it "requires a team" do
    form = WizardForm.new(name: "Untitled wizard", team: nil)

    expect(form.save).to be(false)
    expect(Wizard.count).to eq(0)
  end
end
