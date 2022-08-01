class ContentPagesController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_registered_user!
  before_action :clear_flash

  def index
    first_module_item = ModuleItem.find_by(training_module: training_module)
    redirect_to training_module_content_page_path(training_module, first_module_item)
  end

  def show
    track('module_content_page')
    module_start_event = Ahoy::Event.where(user_id: current_user, name: 'module_start').where_properties(training_module_id: training_module)
    if params[:id] == 'intro' && !module_start_event.exists?
      track('module_start')
    end
    @model = module_item.model
    if @model.is_a?(Questionnaire) || @model.is_a?(AssessmentsResults)
      redirect_to questionnaire_path(training_module, module_item)
    else
      render module_item.type
    end
    mod_progress = ModuleProgress.new(user: current_user, mod: module_item.parent)
    confidence_check_complete_event = Ahoy::Event.where(user_id: current_user, name: 'confidence_questionnaire_complete').where_properties(training_module_id: training_module)
    if mod_progress.completed? && !confidence_check_complete_event.exists?
      track('confidence_questionnaire_complete')
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
