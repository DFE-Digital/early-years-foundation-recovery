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
    Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'completedAt'),
      properties: payload,
    )

    check_new_modules

    # Potentially useful but is a LONG running task and concurrent runs must be avoided
    # TODO: consider que-locks if webhooks are to trigger the worker
    #
    # FillPageViewsJob.enqueue
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

  # @return [void]
  def check_new_modules
    mail_service = NudgeMail.new
    mail_service.call
    existing_modules = TrainingModuleRecord.pluck(:module_id)
    new_modules = Training::Module.ordered.reject { |mod| existing_modules.include?(mod.id) }.reject(&:draft?)
    new_modules.each do |mod|
      unless TrainingModuleRecord.pluck(:name).include?(mod.name)
        mail_service.new_module(mod)
        TrainingModuleRecord.create!(module_id: mod.position, name: mod.name)
      end
    end
  end
end
