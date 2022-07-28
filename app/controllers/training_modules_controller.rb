class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!, only: :show

  def index
    track('course_overview_page')
    @published_modules = TrainingModule.where(draft: nil)
  end

  def show
    track('module_overview_page')
    @training_module = TrainingModule.find_by(name: params[:id])

    mod_progress = ModuleProgress.new(user: current_user, mod: @training_module)
    @module_progress = ModuleOverviewDecorator.new(mod_progress)

    # Render verbose summary of module activity for the current user
    # /modules/alpha?debug=y
    render partial: 'wip' if params[:debug] # && Rails.env.development?
  end

  def certificate
    @training_module = TrainingModule.find_by(name: params[:training_module_id])
    mod_progress = ModuleProgress.new(user: current_user, mod: @training_module)
    @module_progress = ModuleOverviewDecorator.new(mod_progress)
    track('module_complete')
  end
end
