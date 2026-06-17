class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Gate the whole app behind HTTP Basic auth in production while it's only open
  # to invited external testers (issue #30). The /up health check bypasses this
  # because Rails::HealthController doesn't inherit from ApplicationController.
  before_action :authenticate_tester, if: -> { Rails.env.production? }

  # A user acting outside their team is sent back to the dashboard.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :signed_in?, :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Establish a signed-in session. Resets the session first to avoid session
  # fixation.
  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    @current_user = user
  end

  # The team whose dashboard the user is currently looking at. A navigation
  # concern, kept out of the policies (which authorize on membership).
  def current_team
    current_user&.current_team
  end

  def user_not_authorized
    redirect_to wizards_path, alert: "You do not have access to that wizard"
  end

  # Authorize edit access to a wizard's content by team membership. The nested
  # builder controllers (components, branch rules, positions, …) load their
  # child records by id, so the request URL carries no team — without this a
  # signed-in user could reach another team's content by guessing ids. Resolve
  # through the record to its wizard and run WizardPolicy.
  def authorize_wizard(wizard)
    authorize wizard, :update?
  end

  def authenticate_tester
    credentials = Rails.application.credentials.basic_auth
    authenticate_or_request_with_http_basic("GOV.UK Prototype Builder") do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, credentials.username) &
        ActiveSupport::SecurityUtils.secure_compare(password, credentials.password)
    end
  end

  def signed_in?
    current_user.present?
  end

  def require_sign_in
    redirect_to new_sign_in_path unless signed_in?
  end
end
