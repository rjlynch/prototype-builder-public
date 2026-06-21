require "rails_helper"

# A file upload can't ride along in the session cookie like other answers, so
# the answers controller persists it via Active Storage and keeps only the
# blob's signed id as the answer. Run mode (the public share link) needs no
# sign in.
RSpec.describe "File upload answers", type: :request do
  let(:wizard) { Wizard.create!(name: "Upload wizard", team: personal_team) }
  let(:page) { wizard.pages.create!(position: 1, slug: "upload") }

  before do
    page.components.create!(position: 1, kind: "file_upload", name: "question-1", label: "Upload a file")
  end

  it "stores the uploaded file as a blob and keeps its signed id in the session" do
    file = fixture_file_upload("sample.txt", "text/plain")

    expect {
      post page_answers_path(page), params: { answers: { "question-1" => file } }
    }.to change(ActiveStorage::Blob, :count).by(1)

    signed_id = session[:answers][wizard.id.to_s]["question-1"]
    blob = ActiveStorage::Blob.find_signed(signed_id)
    expect(blob.filename.to_s).to eq("sample.txt")
    expect(blob.content_type).to eq("text/plain")
  end

  it "leaves the answer empty when no file is chosen" do
    expect {
      post page_answers_path(page), params: { answers: { "question-1" => "" } }
    }.not_to change(ActiveStorage::Blob, :count)

    expect(session[:answers][wizard.id.to_s]["question-1"]).to eq("")
  end
end
