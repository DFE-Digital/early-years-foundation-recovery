class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!, only: :show

  def index
    track('course_overview_page')
    @published_modules = TrainingModule.where(draft: nil)
  end

  def show
    track('module_overview_page')
    @training_module = TrainingModule.find_by(name: params[:id])
    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))
    @assessment_progress = helpers.assessment_progress(@training_module)

    # Render verbose summary of module activity for the current user
    # /modules/alpha?debug=y
    render partial: 'wip' if params[:debug] # && Rails.env.development?
  end

  def certificate
    @training_module = TrainingModule.find_by(name: params[:training_module_id])
    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))

    track('module_complete') if track_module_complete?

    mod_time.update_time(params[:training_module_id])
  end

private

  def track_module_complete?
    !tracked?('module_complete', training_module_id: @training_module.name)
  end

  def mod_time
    @mod_time ||= ModuleTimeToComplete.new(user: current_user)
  end
end
