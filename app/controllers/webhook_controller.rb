class WebhookController < ApplicationController
  before_action :authenticate_webhook!
  skip_before_action :verify_authenticity_token

private

  def authenticate_webhook!
    render json: { status: 'invalid secure header' }, status: :unauthorized unless bot_token?
  end

  # @return [Hash]
  def payload
    @payload ||= JSON.parse(request.body.read)
  end
end
