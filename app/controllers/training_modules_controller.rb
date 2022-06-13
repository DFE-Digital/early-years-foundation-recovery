class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!

  def index
    @training_modules = TrainingModule.all
  end

  def show
    @training_module = TrainingModule.find_by(name: params[:id])

    @module_item = ModuleItem.where(training_module: params[:id])
  end
end
