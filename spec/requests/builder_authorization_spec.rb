require "rails_helper"

# The page builder mutates a wizard through its child records (components,
# branch rules, positions, …), whose URLs carry only the record id and no team.
# These specs prove a signed-in user cannot reach another team's content by
# guessing those ids — the IDOR the nested controllers would otherwise allow.
RSpec.describe "Builder authorization", type: :request do
  # A wizard owned by a team the signed-in user does NOT belong to.
  let(:other_team) { Team.create!(name: "Other Team") }
  let(:wizard) { Wizard.create!(name: "Theirs", team: other_team) }
  let(:page) { Page.create!(wizard: wizard, position: 1, slug: "start") }
  let(:other_page) { Page.create!(wizard: wizard, position: 2, slug: "next") }
  let(:button) { Component.create!(page: page, position: 1, kind: "button", text: "Continue") }
  let(:branch_rule) { BranchRule.create!(component: button, position: 1, target_slug: "next") }

  # The signed-in user belongs only to their own team.
  let(:my_team) { Team.create!(name: "Mine") }
  let(:user) do
    User.create!(email_address: "me@example.com", full_name: "Me", default_team: my_team).tap do |u|
      Membership.create!(user: u, team: my_team)
    end
  end

  before { post session_path, params: { token: user.generate_token_for(:sign_in) } }

  def expect_blocked
    expect(response).to redirect_to(wizards_path)
    follow_redirect!
    expect(response.body).to include("do not have access")
  end

  it "blocks adding a component to another team's page" do
    expect {
      post page_components_path(page), params: { component: { kind: "paragraph" } }
    }.not_to change(Component, :count)
    expect_blocked
  end

  it "blocks editing another team's component" do
    patch component_path(button), params: { component: { text: "Hacked" } }
    expect_blocked
    expect(button.reload.text).to eq("Continue")
  end

  it "blocks deleting another team's component" do
    button
    expect { delete component_path(button) }.not_to change(Component, :count)
    expect_blocked
  end

  it "blocks adding a branch rule to another team's button" do
    expect {
      post component_branch_rules_path(button)
    }.not_to change(BranchRule, :count)
    expect_blocked
  end

  it "blocks editing another team's branch rule" do
    patch branch_rule_path(branch_rule), params: { branch_rule: { target_slug: "elsewhere" } }
    expect_blocked
    expect(branch_rule.reload.target_slug).to eq("next")
  end

  it "blocks deleting another team's branch rule" do
    branch_rule
    expect { delete branch_rule_path(branch_rule) }.not_to change(BranchRule, :count)
    expect_blocked
  end

  it "blocks reordering another team's component" do
    patch component_position_path(button), params: { direction: "up" }
    expect_blocked
  end

  it "blocks reordering another team's page" do
    other_page
    patch page_position_path(page), params: { position: 2 }
    expect_blocked
  end

  it "blocks inserting a page into another team's wizard" do
    page
    expect { post page_successor_path(page) }.not_to change(Page, :count)
    expect_blocked
  end

  it "blocks creating pages via builder-mode answers in another team's wizard" do
    button
    expect {
      post page_answers_path(page), params: { mode: "builder", button_id: button.id }
    }.not_to change(Page, :count)
    expect_blocked
  end

  # Run mode is the public share link: posting answers without builder mode must
  # still work for anyone, member or not.
  it "still lets anyone walk the journey in run mode" do
    other_page
    post page_answers_path(page), params: { button_id: button.id }

    expect(response).not_to redirect_to(wizards_path)
  end
end
