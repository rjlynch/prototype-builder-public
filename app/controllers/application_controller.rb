class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :signed_in?

  private

  def signed_in?
    session[:signed_in].present?
  end

  def require_sign_in
    redirect_to root_path unless signed_in?
  end
end
