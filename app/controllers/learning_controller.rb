class LearningController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :migrate_progress_if_needed, only: :show
  before_action :set_module_progress_data, only: :show

  helper_method :module_progress

  layout 'hero'

  # GET /my-modules
  def show
    @current_modules = Training::Module.live.select { |mod| started?(mod) && !completed?(mod) }
    @available_modules = Training::Module.live.reject { |mod| started?(mod) || mod.draft? }
    track('learning_page')
  end

  def migrate_progress_if_needed
    return if current_user.user_module_progress.exists?

    has_module_events = current_user.events
      .where(name: %w[module_start module_content_page page_view])
      .exists?

    return unless has_module_events

    Training::Module.live.each do |mod|
      UserModuleProgress.migrate_from_events(user: current_user, module_name: mod.name)
    end
  end

  def set_module_progress_data
    @user_progress_by_module = current_user.user_module_progress.index_by(&:module_name)
    @progress_by_module_id = {}
  end

private

  def started?(mod)
    @user_progress_by_module[mod.name]&.started_at.present?
  end

  def completed?(mod)
    @user_progress_by_module[mod.name]&.completed_at.present?
  end

  def module_progress(mod)
    @progress_by_module_id[mod.name] ||= ModuleOverviewDecorator.new(
      ModuleProgress.new(
        user: current_user,
        mod: mod,
        user_module_progress: @user_progress_by_module[mod.name],
      ),
    )
  end
end
