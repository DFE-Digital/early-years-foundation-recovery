class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!, only: :show

  def index
    track('course_overview_page')
    @published_modules = TrainingModule.where(draft: nil)
  end

  def show
    @training_module = TrainingModule.find_by(name: params[:id])
    @module_progress = ModuleProgress.new(user: current_user, mod: @training_module)
  end
end
