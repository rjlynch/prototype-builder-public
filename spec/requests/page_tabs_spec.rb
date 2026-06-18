require "rails_helper"

# The page tabs show a fixed-size window of pages that slides to keep the
# current page roughly centred, with arrows to the pages on either side. The
# window is computed server-side from the current page, so each navigation
# re-renders the right slice — no JS.
RSpec.describe "Page tabs windowing", type: :request do
  let(:team) { Team.create!(name: "Mine") }
  let(:user) do
    User.create!(email_address: "me@example.com", full_name: "Me", default_team: team).tap do |u|
      Membership.create!(user: u, team: team)
    end
  end
  let(:wizard) { Wizard.create!(name: "Long journey", team: team) }
  # Ten pages, more than the default block of eight.
  let!(:pages) do
    (1..10).map { |n| Page.create!(wizard: wizard, position: n, slug: "page-#{n}") }
  end

  before { post session_path, params: { token: user.generate_token_for(:sign_in) } }

  def nav
    Capybara.string(response.body).find("nav[aria-label='Pages in this wizard']")
  end

  it "clamps to the start with a forward arrow only on the first page" do
    get edit_page_path(pages.first)

    expect(nav).to have_css("li", count: 9) # eight page tabs + one arrow
    expect(nav).to have_link("Show more pages", href: edit_page_path(pages[8]))
    expect(nav).to have_no_link("Show earlier pages")
  end

  it "slides with both arrows when the current page is in the middle" do
    get edit_page_path(pages[4]) # page 5 -> window slides to pages 2..9

    expect(nav).to have_css("li", count: 10) # eight page tabs + two arrows
    expect(nav).to have_link("Show earlier pages", href: edit_page_path(pages[0]))
    expect(nav).to have_link("Show more pages", href: edit_page_path(pages[9]))
  end

  it "clamps to the end with a back arrow only near the last page" do
    get edit_page_path(pages[8]) # page 9 -> window clamps to pages 3..10

    expect(nav).to have_css("li", count: 9) # eight page tabs + one arrow
    expect(nav).to have_link("Show earlier pages", href: edit_page_path(pages[1]))
    expect(nav).to have_no_link("Show more pages")
  end
end
