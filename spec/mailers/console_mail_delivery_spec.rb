require "rails_helper"

RSpec.describe ConsoleMailDelivery do
  let(:mail) do
    Mail.new do
      from    "noreply@example.com"
      to      "tester@example.com"
      subject "Hello"
      body    "A test email"
    end
  end

  it "is registered as the :console Action Mailer delivery method" do
    expect(ActionMailer::Base.delivery_methods[:console]).to eq(described_class)
  end

  it "prints the message to stdout instead of sending it" do
    expect { described_class.new.deliver!(mail) }
      .to output(/tester@example.com.*A test email/m).to_stdout
  end

  it "returns the mail so Action Mailer delivery does not error" do
    suppress_stdout { expect(described_class.new.deliver!(mail)).to eq(mail) }
  end

  def suppress_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end
end
