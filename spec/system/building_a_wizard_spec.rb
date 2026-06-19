require "rails_helper"

# Mirrors the rough spec in the project brief: a non-technical user builds a
# multi-page journey in the page builder while the preview pane updates live.
RSpec.describe "Building a wizard", :js, type: :system do
  it "builds a two-page journey with a live, interactive preview" do
    sign_in
    click_button "New wizard"

    # --- Page 1 ---------------------------------------------------------
    expect(page).to have_no_css("h2", text: "Untitled page")
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls page-1")
    find(".app-disclosure__summary", text: "Page controls").click
    expect(page).to have_field("Page slug", with: "page-1")
    within_preview do
      expect(page).to have_content("Your page preview appears here")
    end

    # The wizard name in the service navigation opens the settings page
    click_link "Untitled wizard"
    expect(page).to have_css("h1", text: "Untitled wizard")
    expect(page).to have_link("Share this wizard")
    expect(page).to have_button("Copy link")
    click_button "Copy link"
    expect(page).to have_button("Copied")
    fill_in "Wizard name", with: "EYTFI claim"
    expect(page).to have_css("h1", text: "EYTFI claim") # the heading echoes the save
    expect(page).to have_content("Saved")
    click_link "Back to the builder"

    fill_in "Page title", with: "Claim an early years teacher recognition payment"
    expect(page).to have_content("Saved")
    within_preview do
      expect(page).to have_css("h1", text: "Claim an early years teacher recognition payment")
    end

    add_component "Add paragraph"
    within_last_card do
      fill_in "Paragraph text", with: "Use this service to claim a recognition payment of £4,5000"
      expect(page).to have_content("Saved")
    end
    within_preview do
      expect(page).to have_css("p", text: "Use this service to claim a recognition payment of £4,5000")
    end

    add_component "Add paragraph"
    within_last_card { fill_in "Paragraph text", with: "Some test copy" }
    within_preview do
      expect(page).to have_css("p", text: "Some test copy")
    end

    within_last_card { fill_in "Paragraph text", with: "some different copy" }
    within_preview do
      expect(page).to have_css("p", text: "some different copy")
      expect(page).to have_no_css("p", text: "Some test copy")
    end

    within_last_card { click_button "Remove paragraph" }
    within_preview do
      expect(page).to have_no_css("p", text: "some different copy")
      expect(page).to have_css("p", text: "Use this service to claim a recognition payment of £4,5000")
    end

    add_component "Add subheading"
    within_last_card { fill_in "Subheading text", with: "Before you start" }
    within_preview do
      expect(page).to have_css("h2", text: "Before you start")
    end

    add_component "Add button"
    within_preview do
      expect(page).to have_button("Continue")
    end

    within_last_card { fill_in "Button text", with: "Start now" }
    within_preview do
      expect(page).to have_button("Start now")
    end

    # Clicking continue in the preview moves to a fresh page and builder
    within_preview { click_button "Start now" }

    # --- Page 2 ---------------------------------------------------------
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls page-2")
    expect(page).to have_field("Page title", with: "")
    within_service_nav { expect(page).to have_link("EYTFI claim") } # rename stuck
    # Back to page 1 (the first tab) via the tab menu
    within_nav { first(".govuk-tabs__tab").click }
    expect(page).to have_css(
      ".app-disclosure__summary",
      text: "Page controls claim-an-early-years-teacher-recognition-payment"
    )
    # Forward again from the preview's continue button (the next-page link is gone)
    within_preview { click_button "Start now" }
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls page-2")
    within_preview do
      expect(page).to have_no_css("h1")
    end

    fill_in "Page title", with: "Which nursery do you teach in?"
    within_preview do
      expect(page).to have_css("h1", text: "Which nursery do you teach in?")
    end

    add_component "Add paragraph"
    within_last_card do
      fill_in "Paragraph text", with: "If you work in more than one setting, choose the one you spend most of your time in."
    end
    within_preview do
      expect(page).to have_css("p", text: "If you work in more than one setting")
    end
    add_component "Add text input"
    within_last_card do
      fill_in "Name", with: "nursery name"
      fill_in "Label", with: "Enter nursery name or postcode"
      fill_in "Hint", with: "Search by name or postcode"
    end
    within_preview do
      expect(page).to have_field("Enter nursery name or postcode")
      expect(page).to have_content("Search by name or postcode")
    end

    add_component "Add button"

    within_preview do
      fill_in "Enter nursery name or postcode", with: "Sunny days nursery"
      click_button "Continue"
    end

    # --- Page 3 ---------------------------------------------------------
    expect(page).to have_css(".app-disclosure__summary", text: "Page controls page-3")
    expect(page).to have_field("Page title", with: "")

    # The renamed wizard shows up on the dashboard
    visit wizards_path
    expect(page).to have_link("EYTFI claim")
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_service_nav(&block)
    within(".govuk-service-navigation", &block)
  end

  def within_nav(&block)
    within("nav[aria-label='Pages in this wizard']", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  # Clicks an "add component" button and waits for the new editor card to
  # appear in the (re-rendered) builder pane.
  def add_component(button_label)
    # The page title card is always present, so the builder has settled once
    # at least one card exists; count from there to avoid a mid-render read.
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
