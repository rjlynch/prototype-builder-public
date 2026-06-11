class SessionsController < ApplicationController
  # Stubbed sign in: no accounts yet, just a session flag. See PLAN.md.
  def create
    session[:signed_in] = true
    redirect_to wizards_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
