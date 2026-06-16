class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Gate the whole app behind HTTP Basic auth in production while it's only open
  # to invited external testers (issue #30). The /up health check bypasses this
  # because Rails::HealthController doesn't inherit from ApplicationController.
  before_action :authenticate_tester, if: -> { Rails.env.production? }

  helper_method :signed_in?

  private

  def authenticate_tester
    credentials = Rails.application.credentials.basic_auth
    authenticate_or_request_with_http_basic("GOV.UK Prototype Builder") do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, credentials.username) &
        ActiveSupport::SecurityUtils.secure_compare(password, credentials.password)
    end
  end

  def signed_in?
    session[:signed_in].present?
  end

  def require_sign_in
    redirect_to root_path unless signed_in?
  end
end
