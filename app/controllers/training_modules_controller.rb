class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!, only: :show

  def index
    track('course_overview_page')
    @published_modules = TrainingModule.published
  end

  def show
    track('module_overview_page')
    @training_module = TrainingModule.find_by(name: params[:id])

    if @training_module.nil? || @training_module.draft?
      redirect_to my_modules_path
    else
      @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))
      @assessment_progress = helpers.assessment_progress(@training_module)

      # OPTIMIZE: instantiation of module_item
      module_item

      render partial: 'progress' if params[:debug] && Rails.env.development?
    end
  end

protected

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module_name, name: params[:id]) || ModuleItem.find_by(training_module: params[:id])
  end

  def training_module_name
    @training_module_name ||= params[:training_module_id]
  end
end
