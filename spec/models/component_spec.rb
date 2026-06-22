require "rails_helper"

RSpec.describe Component do
  it "allows only one input per page to use the title as its label" do
    wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
    page = wizard.pages.create!(position: 1, slug: "page-1")
    page.components.create!(position: 1, kind: "radios", name: "question-1", title_as_label: true)

    duplicate = page.components.new(position: 2, kind: "text_input", name: "question-2", title_as_label: true)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:title_as_label]).to be_present
  end

  it "splits list text into stripped, non-blank items" do
    component = Component.new(text: "  First  \n\nSecond\n")

    expect(component.list_items).to eq([ "First", "Second" ])
  end

  it "is ordered only for the number style" do
    expect(Component.new(list_style: "number")).to be_list_ordered
    expect(Component.new(list_style: "bullet")).not_to be_list_ordered
    expect(Component.new(list_style: "none")).not_to be_list_ordered
  end

  it "gives a GOV.UK modifier class for every button style but the default" do
    expect(Component.new(button_style: "continue").button_modifier_class).to be_nil
    expect(Component.new(button_style: "secondary").button_modifier_class).to eq("govuk-button--secondary")
    expect(Component.new(button_style: "warning").button_modifier_class).to eq("govuk-button--warning")
  end

  it "knows the start button (which renders the arrow icon)" do
    expect(Component.new(button_style: "start")).to be_start_button
    expect(Component.new(button_style: "continue")).not_to be_start_button
  end

  describe "#destination_slug" do
    def button(target_slug: "", rules: [])
      wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
      page = wizard.pages.create!(position: 1, slug: "page-1")
      button = page.components.create!(position: 1, kind: "button", text: "Continue", target_slug: target_slug)
      rules.each_with_index do |rule, i|
        branch_rule = button.branch_rules.create!(position: i + 1, target_slug: rule[:target_slug].to_s)
        branch_rule.conditions.create!(position: 1, input_name: rule[:input_name].to_s, value: rule[:value].to_s)
      end
      button
    end

    it "prefers a matching branch rule over the button's own slug" do
      component = button(target_slug: "summary", rules: [ { input_name: "q-1", value: "no", target_slug: "not-eligible" } ])

      expect(component.destination_slug("q-1" => "no")).to eq("not-eligible")
    end

    it "falls back to the button's own slug when no rule matches" do
      component = button(target_slug: "summary", rules: [ { input_name: "q-1", value: "no", target_slug: "not-eligible" } ])

      expect(component.destination_slug("q-1" => "yes")).to eq("summary")
    end

    it "is nil when there is neither a matching rule nor a slug" do
      expect(button.destination_slug({})).to be_nil
    end
  end

  describe "#uploaded_blob" do
    def file_component(source_key:)
      wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
      page = wizard.pages.create!(position: 1, slug: "page-1")
      page.components.create!(position: 1, kind: "file", source_key: source_key)
    end

    it "resolves the blob from the signed id stored as the answer" do
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("hi"), filename: "photo.png", content_type: "image/png")
      component = file_component(source_key: "question-1")

      expect(component.uploaded_blob("question-1" => blob.signed_id)).to eq(blob)
    end

    it "is nil when the referenced input has no answer" do
      component = file_component(source_key: "question-1")

      expect(component.uploaded_blob({})).to be_nil
    end

    it "is nil when the answer is not a valid signed id" do
      component = file_component(source_key: "question-1")

      expect(component.uploaded_blob("question-1" => "not-a-signed-id")).to be_nil
    end
  end

  describe "#summary_keys" do
    it "reads the chosen input keys, one per line in text" do
      component = Component.new(kind: "check_answers", text: "question-1\nquestion-2\n")

      expect(component.summary_keys).to eq([ "question-1", "question-2" ])
    end
  end

  describe "#summary_answer" do
    def input(kind:, options: "")
      Component.new(kind: kind, name: "question-1", options: options)
    end

    it "passes a text answer through" do
      expect(input(kind: "text_input").summary_answer("question-1" => "Ada")).to eq("Ada")
    end

    it "maps a radio answer back to the option label the user saw" do
      radios = input(kind: "radios", options: "Yes\nNo, not yet")

      expect(radios.summary_answer("question-1" => "no-not-yet")).to eq("No, not yet")
    end

    it "joins the chosen checkbox labels" do
      checkboxes = input(kind: "checkboxes", options: "Email\nText message\nPhone")

      expect(checkboxes.summary_answer("question-1" => [ "", "email", "phone" ])).to eq("Email, Phone")
    end

    it "shows an uploaded file's name" do
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("hi"), filename: "cv.pdf", content_type: "application/pdf")
      upload = input(kind: "file_upload")

      expect(upload.summary_answer("question-1" => blob.signed_id)).to eq("cv.pdf")
    end

    it "reads 'Not answered' when nothing is stored" do
      expect(input(kind: "text_input").summary_answer({})).to eq("Not answered")
    end
  end

  describe "#missing_target?" do
    def button(target_slug:)
      wizard = Wizard.create!(name: "Untitled wizard", team: personal_team)
      page = wizard.pages.create!(position: 1, slug: "page-1")
      wizard.pages.create!(position: 2, slug: "summary")
      page.components.create!(position: 1, kind: "button", text: "Continue", target_slug: target_slug)
    end

    it "is false when the slug is blank" do
      expect(button(target_slug: "")).not_to be_missing_target
    end

    it "is false when a page with that slug exists" do
      expect(button(target_slug: "summary")).not_to be_missing_target
    end

    it "is true when no page has that slug yet" do
      expect(button(target_slug: "not-yet")).to be_missing_target
    end
  end
end
