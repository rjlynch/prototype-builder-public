require "rails_helper"

# The `file` component plays an upload back on a later page: images inline
# (capped to the container), other files (and images, when toggled) as a
# download link. Part 2 of issue #99.
RSpec.describe "File playback components", :js, type: :system do
  # A two-page journey: page 1 uploads, page 2 plays the upload back.
  def build_journey(display_as_link: false)
    wizard = Wizard.create!(name: "Upload journey", team: current_user.default_team)
    page_one = wizard.pages.create!(position: 1, slug: "upload", title: "Upload a photo")
    page_two = wizard.pages.create!(position: 2, slug: "result", title: "Your photo")
    page_one.components.create!(position: 1, kind: "file_upload", name: "question-1", label: "Upload a photo")
    page_one.components.create!(position: 2, kind: "button", text: "Continue")
    page_two.components.create!(position: 1, kind: "file", source_key: "question-1", display_as_link: display_as_link)
    [ page_one, page_two ]
  end

  it "plays an uploaded image back inline on a later page" do
    sign_in
    page_one, = build_journey

    visit page_path(page_one)
    attach_file "answers[question-1]", file_fixture("sample.png"), make_visible: true
    click_button "Continue"

    expect(page).to have_css("h1", text: "Your photo")
    image = find(".app-uploaded-image")
    expect(image[:src]).to include("/rails/active_storage/")
    expect(image[:alt]).to eq("sample.png")
  end

  it "shows a download link instead when the toggle is set" do
    sign_in
    page_one, = build_journey(display_as_link: true)

    visit page_path(page_one)
    attach_file "answers[question-1]", file_fixture("sample.png"), make_visible: true
    click_button "Continue"

    expect(page).to have_css("h1", text: "Your photo")
    expect(page).to have_no_css(".app-uploaded-image")
    expect(page).to have_link("sample.png", href: %r{/rails/active_storage/})
  end

  it "offers the wizard's uploads in the builder and previews a placeholder" do
    sign_in
    click_button "New wizard"

    add_component "Add file upload"
    within_last_card { fill_in "Label", with: "Upload a photo" }
    # Wait for the label's autosubmit to persist before adding the playback
    # component, so its select is built from the saved label.
    within_preview { expect(page).to have_css("label.govuk-label", text: "Upload a photo") }

    add_component "Add uploaded file"
    within_last_card { select "question-1 (Upload a photo)", from: "Show the file uploaded for" }

    within_preview do
      expect(page).to have_content("The file uploaded for “question-1” appears here.")
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
