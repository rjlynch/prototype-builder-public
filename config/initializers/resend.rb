# Resend is the production email provider (see config/environments/production.rb,
# which sets `config.action_mailer.delivery_method = :resend`). The :resend
# delivery method is registered by the gem's railtie and reads this API key.
#
# The key lives in encrypted credentials under `resend.api_key`. It's only used
# in production — development prints emails to the console instead — so a missing
# key in other environments is fine.
Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)
