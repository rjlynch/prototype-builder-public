require "rails_helper"

RSpec.describe NextPageForm do
  it "creates the next page when there is none" do
    wizard = Wizard.create!(name: "Test wizard")
    first = wizard.pages.create!(position: 1)

    form = NextPageForm.new(page: first)

    expect { form.save }.to change(wizard.pages, :count).by(1)
    expect(form.next_page).to have_attributes(position: 2, title: "")
  end

  it "finds the next page when it already exists" do
    wizard = Wizard.create!(name: "Test wizard")
    first = wizard.pages.create!(position: 1)
    second = wizard.pages.create!(position: 2)

    form = NextPageForm.new(page: first)

    expect { form.save }.not_to change(wizard.pages, :count)
    expect(form.next_page).to eq(second)
  end
end
