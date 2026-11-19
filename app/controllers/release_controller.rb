class ReleaseController < WebhookController
  def new
    new_release = Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'completedAt'),
      properties: payload,
    )

    Rails.logger.info('[ReleaseController#new] Clearing module cache after creating new release')
    Training::Module.cache.clear
    Page.reset_cache_key!

    Rails.logger.info("[ReleaseController#new]
      Created Release with ID: #{new_release.id}, sys_id: #{payload.dig('sys', 'id')}")

    NewModuleMailJob.enqueue(new_release.id)

    render json: { status: 'content release received' }, status: :ok
  end

  def update
    release = Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'updatedAt'),
      properties: payload,
    )

    Rails.logger.info('[ReleaseController#update] Clearing module cache after updating release')
    Training::Module.cache.clear
    Page.reset_cache_key!

    Rails.logger.info("[ReleaseController#update]
      Created Release with ID: #{release.id}, sys_id: #{payload.dig('sys', 'id')}")

    ContentCheckJob.enqueue

    render json: { status: 'content change received' }, status: :ok
  end
end
