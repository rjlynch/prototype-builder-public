require "rails_helper"

# The branching scenario from the brief: an "Are you eligible?" radio
# question whose continue button routes yes -> congratulations and
# no -> you-are-not-eligible.
RSpec.describe "Branching a wizard", :js, type: :system do
  it "routes to different pages depending on a radio answer" do
    visit root_path
    click_button "Sign in"
    click_button "New wizard"

    fill_in "Page title", with: "Are you eligible?"
    expect(page).to have_field("Page slug", with: "are-you-eligible")
    expect(page).to have_css("h2", text: "Are you eligible?")

    find("summary", text: "Add input").click
    add_component "Radio buttons"
    within_last_card do
      fill_in "Label", with: "Are you eligible?"
      fill_in "Options (one per line)", with: "yes\nno"
    end
    within_preview do
      expect(page).to have_css(".govuk-radios__label", text: "yes")
      expect(page).to have_css(".govuk-radios__label", text: "no")
    end

    add_component "Add continue button"

    # First rule: yes -> congratulations
    add_rule
    within_last_condition do
      select "question-1", from: "When answer to"
      fill_in "Is", with: "yes"
      fill_in "Go to page", with: "congratulations"
    end
    within_preview do
      expect(page).to have_content("go to congratulations")
    end

    # Second rule: no -> you-are-not-eligible
    add_rule
    within_last_condition do
      select "question-1", from: "When answer to"
      fill_in "Is", with: "no"
      fill_in "Go to page", with: "You are not eligible"
    end
    within_preview do
      expect(page).to have_content("go to you-are-not-eligible")
    end

    # Answer yes: a blank "congratulations" page is created and we land
    # on its builder
    within_preview do
      choose "yes"
      click_button "Continue"
    end
    expect(page).to have_field("Page slug", with: "congratulations")
    expect(page).to have_field("Page title", with: "")

    # Back on the question page, answer no instead
    click_link "are-you-eligible"
    within_preview do
      choose "no"
      click_button "Continue"
    end
    expect(page).to have_field("Page slug", with: "you-are-not-eligible")
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def within_last_condition(&block)
    within(all(".app-condition").last, &block)
  end

  def add_component(button_label)
    count = all(".app-card", minimum: 0).size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end

  def add_rule
    count = all(".app-condition", minimum: 0).size
    click_button "Add rule"
    expect(page).to have_css(".app-condition", count: count + 1)
  end
end
