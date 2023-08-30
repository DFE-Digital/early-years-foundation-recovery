# TODO: version history, content delta, author history, publish history
class HookController < ApplicationController
  before_action :authenticate_hook!
  skip_before_action :verify_authenticity_token, only: %i[release change]

  # @note
  #   Production deployment via Delivery API
  #
  #   Other API events:
  #     - Release (execute)
  #
  def release
    new_release = Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'completedAt'),
      properties: payload,
    )

    # TODO: change back to enqueue before merging
    # NewModuleMailJob.run(new_release.id)
    # TODO: uncomment NewModuleMailJob when QA is complete
    CompleteRegistrationMailJob.run
    render json: { status: 'content release received' }, status: :ok
  end

  # @note
  #   Staging deployment via Preview API
  #
  #   Content Event Triggers:
  #     - Autosave (Entry, Asset)
  #     - Publish (Entry 'static' only)
  #
  def change
    Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'updatedAt'),
      properties: payload,
    )

    ContentCheckJob.enqueue

    render json: { status: 'content change received' }, status: :ok
  end

private

  def authenticate_hook!
    render json: { status: 'invalid secure header' }, status: :unauthorized unless bot_token?
  end

  # @return [Hash]
  def payload
    @payload ||= JSON.parse(request.body.read)
  end
end
