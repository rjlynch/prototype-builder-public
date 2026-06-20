require "rails_helper"

# Radio and checkbox option labels accept the same markdown as body copy, so a
# label can carry a link (e.g. consent: "I agree to the terms"). The submitted
# value uses the plain text, so branch rules still match on the readable words.
RSpec.describe "Links in option labels", :js, type: :system do
  it "renders a link in a checkbox label and stores the plain-text value" do
    sign_in
    click_button "New wizard"

    add_component "Add checkboxes"
    within_last_card do
      fill_in "Label", with: "Consent"
      fill_in "Options (one per line)", with: "I agree to the [terms](https://www.gov.uk)"
    end

    within_preview do
      expect(page).to have_link("terms", href: "https://www.gov.uk")
      expect(page).to have_css(".govuk-checkboxes__label", text: "I agree to the terms")
      # The value is the plain text parameterised, so a branch rule typed as
      # "I agree to the terms" matches it.
      expect(page).to have_css(
        "input[type=checkbox][value='i-agree-to-the-terms']", visible: :all
      )
    end

    # The link carries through to run mode.
    wizard = Wizard.last
    visit page_path(wizard.pages.first)
    expect(page).to have_link("terms", href: "https://www.gov.uk")
  end

  it "renders a link in a radio label" do
    sign_in
    click_button "New wizard"

    add_component "Add radio buttons"
    within_last_card do
      fill_in "Label", with: "Have you read the guidance?"
      fill_in "Options (one per line)", with: "Yes, I have read the [guidance](https://www.gov.uk)\nNo"
    end

    within_preview do
      expect(page).to have_link("guidance", href: "https://www.gov.uk")
      expect(page).to have_css(
        "input[type=radio][value='yes-i-have-read-the-guidance']", visible: :all
      )
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    expect(page).to have_css(".app-card", minimum: 1)
    within(all(".app-card").last, &block)
  end

  def add_component(button_label)
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
