require "rails_helper"

# A file upload field lets people attach a document or image, using the
# JS-enhanced ("improved") GOV.UK component.
# https://design-system.service.gov.uk/components/file-upload/
RSpec.describe "File upload components", :js, type: :system do
  it "previews as a GOV.UK file upload in the builder" do
    sign_in
    click_button "New wizard"

    add_component "Add file upload"
    within_last_card do
      fill_in "Label", with: "Upload your evidence"
      fill_in "Hint", with: "PDF or photo"
    end

    within_preview do
      expect(page).to have_css("label.govuk-label", text: "Upload your evidence")
      expect(page).to have_css(".govuk-hint", text: "PDF or photo")
      expect(page).to have_css(".govuk-drop-zone[data-module='govuk-file-upload']")
      expect(page).to have_css("input[type=file][name='answers[question-1]']", visible: :all)
    end
  end

  it "renders the improved (JS-enhanced) component in run mode" do
    sign_in
    click_button "New wizard"

    add_component "Add file upload"
    within_last_card { fill_in "Label", with: "Upload your evidence" }
    within_preview { expect(page).to have_css(".govuk-drop-zone[data-module='govuk-file-upload']") }

    wizard = Wizard.last
    visit page_path(wizard.pages.first)

    # initAll runs on the full page load, so the input is replaced by the
    # enhanced button + status.
    expect(page).to have_button("Choose file")
    expect(page).to have_content("No file chosen")
    expect(page).to have_css("input[type=file][name='answers[question-1]']", visible: :all)
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
