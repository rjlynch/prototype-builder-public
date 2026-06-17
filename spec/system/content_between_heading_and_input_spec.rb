require "rails_helper"

# Issue #74 — the EYTRP "Do you hold one of these teaching qualifications?"
# page asks a radio question that also serves as the page heading, with a
# paragraph and a list of qualifications shown between the heading and the
# options. Because the H1 now sits at the top of the page (the radios fieldset
# references it with aria-labelledby) rather than inside the legend, ordinary
# components can be positioned between the two.
RSpec.describe "Content between a heading-as-label and its input", :js, type: :system do
  it "renders copy and a list between the page heading and the radio options" do
    sign_in
    click_button "New wizard"

    fill_in "Page title", with: "Do you hold one of these teaching qualifications?"
    # Wait for the title to persist (preview reflects it) before the next
    # builder re-render, so the pending autosubmit isn't discarded.
    within_preview { expect(page).to have_css("h1", text: "Do you hold one of these teaching qualifications?") }

    # The question is the radios, using the page title as its legend.
    add_component "Add radio buttons"
    within_last_card do
      fill_in "Options (one per line)", with: "Yes\nNo"
      check "Use the page title as the label"
    end
    within_preview { expect(page).to have_css(".govuk-radios__label", text: "Yes") }

    # Copy, moved above the radios.
    add_component "Add paragraph"
    within_last_card { fill_in "Paragraph text", with: "You must hold one of the following to be eligible:" }
    within_preview { expect(page).to have_css("p.govuk-body", text: "You must hold one of the following") }
    click_button "Move paragraph up"

    # A list, moved above the radios (so it lands between the copy and options).
    add_component "Add list"
    within_last_card { fill_in "List items (one per line)", with: "QTS\nEYTS\nEYPS" }
    within_preview { expect(page).to have_css("ul.govuk-list li", text: "QTS") }
    click_button "Move list up"

    within_preview do
      # One H1, at the top of the page.
      expect(page).to have_css("h1.govuk-heading-l", text: "Do you hold one of these teaching qualifications?")
      expect(page).to have_css("h1", count: 1)

      # Document order: heading, copy, list, then the radio options.
      sequence = all("h1.govuk-heading-l, p.govuk-body, ul.govuk-list, fieldset.govuk-fieldset").map(&:tag_name)
      expect(sequence).to eq(%w[ h1 p ul fieldset ])

      # The copy and list sit outside the fieldset, not swallowed into it.
      within("fieldset.govuk-fieldset") { expect(page).to have_no_css("ul.govuk-list, p.govuk-body") }

      # The fieldset is still associated with the heading for screen readers.
      heading_id = find("h1.govuk-heading-l")[:id]
      expect(find("fieldset.govuk-fieldset")[:"aria-labelledby"]).to eq(heading_id)
    end
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def within_last_card(&block)
    within(all(".app-card").last, &block)
  end

  def add_component(button_label)
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
