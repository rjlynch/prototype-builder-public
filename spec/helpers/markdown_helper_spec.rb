require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#govuk_markdown" do
    it "returns blank for nil or empty input" do
      expect(helper.govuk_markdown(nil)).to eq("")
      expect(helper.govuk_markdown("")).to eq("")
    end

    it "renders **bold** as a GOV.UK-weighted strong element" do
      expect(helper.govuk_markdown("a **strong** word"))
        .to eq(%(a <strong class="govuk-!-font-weight-bold">strong</strong> word))
    end

    it "renders an external [link](url) as a govuk-link anchor" do
      expect(helper.govuk_markdown("see [GOV.UK](https://www.gov.uk)"))
        .to eq(%(see <a class="govuk-link" href="https://www.gov.uk">GOV.UK</a>))
    end

    it "keeps #heading anchors as-is" do
      expect(helper.govuk_markdown("[jump](#eligibility)"))
        .to eq(%(<a class="govuk-link" href="#eligibility">jump</a>))
    end

    it "escapes HTML in the source so it cannot inject markup" do
      expect(helper.govuk_markdown("<script>alert(1)</script>"))
        .to eq("&lt;script&gt;alert(1)&lt;/script&gt;")
    end

    it "neutralises unknown link targets, including javascript: schemes" do
      expect(helper.govuk_markdown("[x](javascript:alert)"))
        .to eq(%(<a class="govuk-link" href="#">x</a>))
    end

    context "with a page for internal links" do
      let(:wizard) { Wizard.create!(name: "Test", team: personal_team) }
      let!(:source) { wizard.pages.create!(position: 1, title: "Start", slug: "start") }
      let!(:target) { wizard.pages.create!(position: 2, title: "Next", slug: "next-page") }

      it "resolves a sibling page slug to its path" do
        expect(helper.govuk_markdown("[go](next-page)", page: source))
          .to eq(%(<a class="govuk-link" href="#{page_path(target)}">go</a>))
      end

      it "leaves an unknown slug inert" do
        expect(helper.govuk_markdown("[go](nope)", page: source))
          .to eq(%(<a class="govuk-link" href="#">go</a>))
      end
    end
  end
end
