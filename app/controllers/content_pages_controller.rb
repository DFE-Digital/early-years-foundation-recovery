class ContentPagesController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :clear_flash

  def index
    first_module_item = ModuleItem.find_by(training_module: training_module_name)
    redirect_to training_module_content_page_path(training_module_name, first_module_item)
  end

  def show
    track('module_content_page')

    @model = module_item.model

    if @model.is_a?(Questionnaire) || @model.is_a?(AssessmentsResults)
      redirect_to questionnaire_path(training_module_name, module_item)
    else
      render module_item.type
    end
  end

private

  def module_item
    @module_item ||= ModuleItem.find_by!(training_module: training_module_name, name: params[:id])
  end

  def training_module_name
    @training_module_name ||= params[:training_module_id]
  end
end
