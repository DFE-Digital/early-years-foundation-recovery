class ContentPagesController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :clear_flash
  helper_method :module_item, :training_module

  def index
    first_module_item = ModuleItem.find_by(training_module: training_module_name)
    redirect_to training_module_content_page_path(training_module_name, first_module_item)
  end

  def show
    track('module_content_page')
    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(module_item.parent))
    @model = module_item.model

    if @model.is_a?(Questionnaire)
      redirect_to training_module_questionnaire_path(training_module_name, module_item)
    elsif module_item.assessment_results?
      redirect_to training_module_assessment_result_path(training_module_name, module_item)
    else
      render content_page_partial(module_item)
    end
  end

private

  def module_item
    @module_item ||= ModuleItem.find_by!(training_module: training_module_name, name: module_params[:id])
  end

  def training_module
    module_item.parent
  end

  def training_module_name
    @training_module_name ||= module_params[:training_module_id]
  end

  def content_page_partial(module_item)
    case module_item.type
    when /intro/ then 'intro_page'
    else
      module_item.type
    end
  end

  def module_params
    params.permit(:training_module_id, :id)
  end
end
