require "rails_helper"

# Each editor card's form is namespaced (see components/_editor.html.erb) so
# its fields get component-scoped ids. Without that, every editor of the same
# kind shares ids like "component_text"; when the autosubmit round-trip
# re-renders the preview, Turbo restores focus by id and lands on the first
# match, bouncing focus to the wrong card while the user is mid-type.
RSpec.describe "Editor field focus", :js, type: :system do
  it "keeps focus in the card being typed in when a second card of the same kind exists" do
    sign_in
    click_button "New wizard"

    add_component "Add paragraph"
    add_component "Add paragraph"

    second = within(all(".app-card").last) { find("textarea") }
    second.click

    # Record whether focus ever bounces to a *different* textarea (the bug);
    # the flag latches so a later check still sees a momentary bounce.
    page.execute_script(<<~JS)
      window.__focusBounced = false;
      const typing = document.activeElement;
      document.addEventListener("focusin", (e) => {
        if (e.target.tagName === "TEXTAREA" && e.target !== typing) {
          window.__focusBounced = true;
        }
      });
    JS

    second.send_keys("second paragraph")

    # Waiting for the preview to reflect the change is a deterministic anchor:
    # it only renders after the autosubmit round-trip and Turbo's focus
    # restoration, which is when the bounce would have happened.
    within_preview { expect(page).to have_css("p", text: "second paragraph") }

    expect(page.evaluate_script("window.__focusBounced")).to be(false)
    expect(second.value).to eq("second paragraph")
    expect(all("textarea").first.value).to eq("") # the first paragraph stayed put
  end

  def within_preview(&block)
    within(".app-split-pane__pane--framed", &block)
  end

  def add_component(button_label)
    # The page title card is always present, so the builder has settled once
    # at least one card exists; count from there to avoid a mid-render read.
    expect(page).to have_css(".app-card", minimum: 1)
    count = all(".app-card").size
    click_button button_label
    expect(page).to have_css(".app-card", count: count + 1)
  end
end
