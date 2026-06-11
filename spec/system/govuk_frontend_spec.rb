require "rails_helper"

# Proves the vendored govuk-frontend CSS and JS are correctly wired into the
# asset pipeline and importmap. Replaces the original boot smoke test.
RSpec.describe "GOV.UK Frontend assets", :js, type: :system do
  it "loads the CSS and initialises the JS" do
    visit root_path

    # initAll() ran: the inline script adds js-enabled/govuk-frontend-supported
    expect(page).to have_css("body.govuk-frontend-supported")

    # The stylesheet applied: GOV.UK green button (v6 brand refresh #0f7a52)
    button_colour = page.evaluate_script(
      "getComputedStyle(document.querySelector('.govuk-button')).backgroundColor"
    )
    expect(button_colour).to eq("rgb(15, 122, 82)")
  end
end
