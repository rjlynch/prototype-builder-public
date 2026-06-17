require "rails_helper"

RSpec.describe DestroySignupJob do
  it "destroys a pending signup" do
    signup = Signup.create!(email_address: "pending@example.com", full_name: "Pending")

    described_class.perform_now(signup.id)

    expect(Signup.exists?(signup.id)).to be(false)
  end

  it "is a no-op when the signup is already gone" do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end
end
