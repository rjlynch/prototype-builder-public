require "rails_helper"

RSpec.describe "Smoke test", :js, type: :system do
  it "boots the app in a real browser" do
    visit "/up"
    expect(page.html).to include("background-color: green")
  end
end
