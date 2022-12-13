class ContentPagesController < ApplicationController
  include Tracking

  before_action :authenticate_registered_user!
  before_action :clear_flash
  helper_method :module_item, :training_module, :note
  after_action :track_events, only: :show

  def index
    first_module_item = ModuleItem.find_by(training_module: training_module_name)
    redirect_to training_module_content_page_path(training_module_name, first_module_item)
  end

  def show
    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(training_module))
    @model = module_item.model

    if @model.is_a?(Questionnaire)
      redirect_to training_module_questionnaire_path(training_module_name, module_item)
    elsif module_item.assessment_results?
      redirect_to training_module_assessment_result_path(training_module_name, module_item)
    else
      render_page
    end
  end

private

  def module_item
    @module_item ||= ModuleItem.find_by!(training_module: training_module_name, name: module_params[:id])
  end

  def training_module
    module_item.parent
  end

  def note
    @note ||= current_user.notes.where(training_module: training_module_name, name: module_params[:id]).first_or_initialize(title: module_item.model.heading)
  end

  def training_module_name
    @training_module_name ||= module_params[:training_module_id]
  end

  def render_page
    render module_item.type
  rescue ActionView::MissingTemplate
    render 'text_page'
  end

  def module_params
    params.permit(:training_module_id, :id)
  end

end
