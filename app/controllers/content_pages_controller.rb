class ContentPagesController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_registered_user!
  before_action :clear_flash

  def index
    first_module_item = ModuleItem.find_by(training_module: training_module)
    redirect_to training_module_content_page_path(training_module, first_module_item)
  end

  def show
    ahoy.track "Viewing #{params[:id]}", request.path_parameters
    @model = module_item.model
    if @model.is_a?(Questionnaire) || @model.is_a?(AssessmentsResults)
      redirect_to questionnaire_path(training_module, module_item) 
    else
      render module_item.type
    end
  end

private

  def module_item
    @module_item ||= ModuleItem.find_by!(training_module: training_module, name: params[:id])
  end

  def training_module
    @training_module ||= params[:training_module_id]
  end
end
