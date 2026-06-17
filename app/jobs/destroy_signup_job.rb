class DestroySignupJob < ApplicationJob
  # Clean up a pending signup that was never confirmed. Enqueued with a delay of
  # Signup::EXPIRY when the signup is created. If the user confirmed in time the
  # signup is already gone, so this is a harmless no-op.
  def perform(signup_id)
    Signup.find_by(id: signup_id)&.destroy
  end
end
