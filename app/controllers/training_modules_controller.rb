class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!

  def index
    @training_modules = TrainingModule.all
  end

  def show
    @training_module = TrainingModule.find_by(name: params[:id])
    @module_progress = ModuleProgress.new(user: current_user, mod: @training_module)
  end
end
