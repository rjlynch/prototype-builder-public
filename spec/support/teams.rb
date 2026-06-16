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
      email_address: ApplicationController::HARDCODED_USER_EMAIL,
      full_name: "Richard Lynch",
      default_team: personal_team
    ).tap { |user| Membership.create!(user: user, team: personal_team) }
  end
end

RSpec.configure do |config|
  config.include TeamHelpers

  # Drive the app as the hardcoded current user wherever a request hits the
  # controllers.
  config.before(:each, type: :system) { current_user }
  config.before(:each, type: :request) { current_user }
end
