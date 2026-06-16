class WebhookController < ApplicationController
  before_action :authenticate_webhook!

  # Contentful won't send a CSRF token, so skip this check for webhooks
  skip_before_action :verify_authenticity_token

private

  def authenticate_webhook!
    enforce_bot_auth!(scope: webhook_auth_scope, valid: webhook_token?)
  end

  def webhook_auth_scope
    'contentful-webhook'
  end

  def webhook_token?
    token = request.headers['BOT'].to_s
    expected = Rails.configuration.contentful_webhook_token.to_s

    token.present? && expected.present? &&
      ActiveSupport::SecurityUtils.secure_compare(token, expected)
  end

  # @return [Hash]
  def payload
    @payload ||= JSON.parse(request.body.read)
  end
end
