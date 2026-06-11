require "rails_helper"

RSpec.describe WizardNameForm do
  it "renames the wizard" do
    wizard = Wizard.create!(name: "Untitled wizard")

    form = WizardNameForm.new(wizard: wizard, name: "EYTFI claim")

    expect(form.save).to be(true)
    expect(wizard.reload.name).to eq("EYTFI claim")
  end

  it "keeps the old name when blank is submitted" do
    wizard = Wizard.create!(name: "Untitled wizard")

    form = WizardNameForm.new(wizard: wizard, name: "")

    expect(form.save).to be(false)
    expect(wizard.reload.name).to eq("Untitled wizard")
  end
end
