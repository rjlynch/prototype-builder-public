require "rails_helper"

# The page tabs show only a fixed-size block of pages around the current one,
# with arrows to the pages on either side. The window is computed server-side
# from the current page, so each navigation re-renders the right block — no JS.
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

  it "shows the first block with a forward arrow only" do
    get edit_page_path(pages.first)

    expect(nav).to have_css("li", count: 9) # eight page tabs + one arrow
    expect(nav).to have_link("Show more pages", href: edit_page_path(pages[8]))
    expect(nav).to have_no_link("Show earlier pages")
  end

  it "shows the next block with a back arrow when the current page sits in it" do
    get edit_page_path(pages[8]) # page 9 -> second block (pages 9, 10)

    expect(nav).to have_css("li", count: 3) # two page tabs + one arrow
    expect(nav).to have_link("Show earlier pages", href: edit_page_path(pages[7]))
    expect(nav).to have_no_link("Show more pages")
  end
end
