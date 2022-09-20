class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!, only: :show
  before_action :track_events, only: :show

  def index
    track('course_overview_page')
    @published_modules = TrainingModule.where(draft: nil)
  end

  def show
    @training_module = TrainingModule.find_by(name: params[:id])
    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))
    @assessment_progress = helpers.assessment_progress(@training_module)
    module_item
    # Render verbose summary of module activity for the current user
    # /modules/alpha?debug=y
    render partial: 'wip' if params[:debug] # && Rails.env.development?
  end

protected

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module_name, name: params[:id]) || ModuleItem.find_by(training_module: params[:id])
  end

  def training_module_name
    @training_module_name ||= params[:training_module_id]
  end

private

  def module_complete_untracked?
    return false if untracked?('module_start', training_module_id: @training_module.name)

    untracked?('module_complete', training_module_id: @training_module.name)
  end

  def track_events
    track('module_overview_page')

    if module_complete_untracked?
      track('module_complete')

      helpers.calculate_module_state
    end
  end
end
