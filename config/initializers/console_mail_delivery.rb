# A tiny Action Mailer delivery method that prints the full message to the
# console (and the Rails log) instead of sending it. Development uses this so
# emails are visible in the server output without any external service or
# inbox — see `config.action_mailer.delivery_method = :console` in
# config/environments/development.rb.
class ConsoleMailDelivery
  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(mail)
    message = "\n== Email (not sent; delivery_method = :console) ==\n" \
              "#{mail}\n" \
              "=================================================\n"
    $stdout.puts(message)
    Rails.logger.info(message)
    mail
  end
end

ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :console, ConsoleMailDelivery
end
