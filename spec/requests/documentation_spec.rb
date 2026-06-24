require "rails_helper"

RSpec.describe "Documentation", type: :request do
  it "is publicly accessible" do
    get documentation_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Build a prototype")
  end

  it "has stable section anchors for deep links" do
    get documentation_path

    expect(response.body).to include('id="wizard-overview-page"')
    expect(response.body).to include('id="page-editor"')
    expect(response.body).to include('id="branch-rules"')
  end

  it "is linked from the landing page before account creation" do
    get root_path

    documentation_link_position = response.body.index("Read the documentation")
    create_account_position = response.body.index("Create an account")

    expect(documentation_link_position).to be < create_account_position
    expect(response.body).to include(%(href="#{documentation_path}"))
  end
end
