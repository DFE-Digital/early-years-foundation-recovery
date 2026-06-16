# Notify only supports a single callback URL
#
class NotifyController < WebhookController
  # @see https://docs.notifications.service.gov.uk/ruby.html#delivery-receipts
  def update
    if recipient
      recipient.update!(notify_callback: payload)
      mail_event.update!(callback: payload) if mail_event
      render json: { status: 'callback received' }, status: :ok
    else
      render json: { status: 'callback received' }, status: :not_modified
    end
  end

private

  def webhook_auth_scope
    'notify-webhook'
  end

  def webhook_token?
    token = bearer_token
    expected = Rails.configuration.notify_webhook_token.to_s

    token.present? && expected.present? &&
      ActiveSupport::SecurityUtils.secure_compare(token, expected)
  end

  def bearer_token
    request.authorization.to_s.split(' ', 2).last.to_s
  end

  # @return [User, nil]
  def recipient
    User.find_by(email: payload['to'])
  end

  # @return [MailEvent, nil]
  def mail_event
    recipient.mail_events.where(template: payload['template_id'], callback: nil).last
  end
end
