class NotifyController < WebhookController
  # @see https://docs.notifications.service.gov.uk/ruby.html#delivery-receipts
  def update
    if user
      user.update!(notify_callback: payload)
      mail_event.update!(callback: payload) if mail_event
      render json: { status: 'callback received' }, status: :ok
    else
      render json: { status: 'callback received' }, status: :not_modified
    end
  end

private

  # @return [Boolean]
  def bot_token?
    request.headers['Authorization']&.include?(Rails.configuration.bot_token)
  end

  # @return [User]
  def user
    User.find_by(email: payload['to'])
  end

  # @return [MailEvent]
  def mail_event
    user.mail_events.where(template: payload['template']).last
  end
end
