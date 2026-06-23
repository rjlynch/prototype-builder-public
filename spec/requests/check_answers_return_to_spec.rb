require "rails_helper"

# A check-answers Change link sends the user back to a question with
# return_to=<summary slug>. On Continue the answers controller honours it,
# returning them to the summary page instead of following normal navigation
# (here the linear next page). Run mode (the public share link) needs no sign in.
RSpec.describe "Check answers return_to", type: :request do
  let(:wizard) { Wizard.create!(name: "Eligibility", team: personal_team) }
  let(:question) { wizard.pages.create!(position: 1, slug: "your-name") }
  let(:next_step) { wizard.pages.create!(position: 2, slug: "next-step") }
  let(:summary) { wizard.pages.create!(position: 3, slug: "check-answers") }

  before do
    next_step && summary
    question.components.create!(position: 1, kind: "text_input", name: "question-1", label: "Your name")
    question.components.create!(position: 2, kind: "button", text: "Continue")
  end

  it "returns to the summary page when return_to names one, overriding linear navigation" do
    post page_answers_path(question), params: { answers: { "question-1" => "Ada" }, return_to: summary.slug }

    expect(response).to redirect_to(page_path(summary))
    expect(session[:answers][wizard.id.to_s]["question-1"]).to eq("Ada")
  end

  it "follows normal navigation when return_to is absent" do
    post page_answers_path(question), params: { answers: { "question-1" => "Ada" } }

    expect(response).to redirect_to(page_path(next_step))
  end

  it "ignores a return_to that names no page in the wizard" do
    post page_answers_path(question), params: { answers: { "question-1" => "Ada" }, return_to: "nope" }

    expect(response).to redirect_to(page_path(next_step))
  end
end
