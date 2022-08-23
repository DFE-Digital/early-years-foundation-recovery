class AssessmentResultsController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :clear_flash

  def new
    helpers.assessment_progress(training_module).archive_attempt
    redirect_to training_module_content_page_path(training_module, training_module.assessment_intro_page)
  end

  def show
    @assessment = helpers.assessment_progress(training_module)
    @module_item = ModuleItem.find_by(training_module: params[:training_module_id], name: params[:id])
  end

private

  def training_module
    @training_module ||= TrainingModule.find_by(name: params[:training_module_id])
  end
end
