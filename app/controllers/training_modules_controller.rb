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
  end
end
