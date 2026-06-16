# Until magic-link sign in lands (issue #32), the app resolves a single
# hardcoded current user from the database. These helpers give specs that user
# and a team to hang wizards off.
module TeamHelpers
  # A team to own test wizards. Memoised per example.
  def personal_team
    @personal_team ||= Team.create!(name: "Personal Team")
  end

  # The hardcoded current user (see ApplicationController) and their membership
  # of personal_team. Any request that goes through authorization needs this to
  # exist in the database.
  def current_user
    @current_user ||= User.create!(
      email_address: "rjlynchdev@example.com",
      full_name: "Richard Lynch",
      default_team: personal_team
    ).tap { |user| Membership.create!(user: user, team: personal_team) }
  end

  # Sign a user in by walking the real magic-link confirmation step, so system
  # specs exercise the same path a person does without going through email.
  def sign_in(user = current_user)
    visit new_session_path(token: user.generate_token_for(:sign_in))
    click_button "Sign in"
    # Wait for the redirect to land before returning. Under the JS driver this
    # ensures the session cookie is set before the spec navigates on.
    expect(page).to have_current_path(wizards_path)
  end
end

RSpec.configure do |config|
  config.include TeamHelpers
end
