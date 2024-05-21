class NotifyController < WebhookController
  # @see https://docs.notifications.service.gov.uk/ruby.html#delivery-receipts
  def update
    user = User.find_by(email: payload['to'])
    user.update!(notify_callback: payload) if user
    render json: { status: 'callback received' }, status: :ok
  end

private

  # @return [String]
  def bot_token?
    request.headers['Authorization']&.include?(Rails.configuration.bot_token)
  end
end
