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
    all_events = current_user.events.where_properties(training_module_id: mod_names)
    grouped = all_events.group_by { |e| e.properties['training_module_id'] }

    @progress_by_module_id = modules.index_with do |mod|
      ModuleOverviewDecorator.new(
        ModuleProgress.new(user: current_user, mod: mod, events_by_module_name: grouped)
      )
    end
  end

private

  # Assuming you preload @progress_by_module_id hash mapping mod.id to ModuleOverviewDecorator

  def module_progress(mod)
    @progress_by_module_id[mod.id] || ModuleOverviewDecorator.new(ModuleProgress.new(user: current_user, mod: mod))
  end

end
