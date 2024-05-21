class ReleaseController < WebhookController
  # @note
  #   Production deployment via Delivery API
  #
  #   Other API events:
  #     - Release (execute)
  #
  def new
    new_release = Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'completedAt'),
      properties: payload,
    )

    NewModuleMailJob.enqueue(new_release.id)

    render json: { status: 'content release received' }, status: :ok
  end

  # @note
  #   Staging deployment via Preview API
  #
  #   Content Event Triggers:
  #     - Autosave (Entry, Asset)
  #     - Publish (Entry 'static' only)
  #
  def update
    Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'updatedAt'),
      properties: payload,
    )

    ContentCheckJob.enqueue

    render json: { status: 'content change received' }, status: :ok
  end
end
