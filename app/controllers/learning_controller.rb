class LearningController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :set_module_progress_data, only: :show

  helper_method :module_progress

  layout 'hero'

  # GET /my-modules
  def show
    track('learning_page')
  end

  def set_module_progress_data
    modules = current_user.course.current_modules
    mod_names = modules.map(&:name)

    # Preload once
    user_module_events = current_user.events.where_properties(training_module_id: mod_names)

    @progress_by_module_id = modules.index_with do |mod|
      ModuleOverviewDecorator.new(
        ModuleProgress.new(user: current_user, mod: mod, user_module_events: user_module_events),
      )
    end
  end

private

  # Assuming you preload @progress_by_module_id hash mapping mod.id to ModuleOverviewDecorator

  def module_progress(mod)
    @progress_by_module_id[mod.name] ||= begin
      user_module_events = current_user.events.where_properties(training_module_id: mod.name)
      ModuleOverviewDecorator.new(
        ModuleProgress.new(user: current_user, mod: mod, user_module_events: user_module_events),
      )
    end
  end
end
