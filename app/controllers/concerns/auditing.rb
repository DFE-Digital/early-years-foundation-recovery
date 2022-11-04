# Bypass authentication using HTTP Header for automated accessibility audit
#
module Auditing
  extend ActiveSupport::Concern

private

  # @return [User]
  def bot
    User.find_by(email: bot_email)
  end

  # @return [Boolean]
  def bot?
    bot_request.present? && bot.present? && bot_token?
  end

  # @return [String]
  def bot_request
    request.headers['BOT']
  end

  # @see lib/tasks/bot.rake
  # @return [String]
  def bot_email
    "#{Rails.configuration.bot_token}@example.com"
  end

  # @return [Boolean]
  def bot_token?
    Rails.configuration.bot_token == bot_request
  end
end
