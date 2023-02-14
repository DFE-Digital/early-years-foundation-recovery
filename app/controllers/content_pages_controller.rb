class ContentPagesController < ApplicationController
  before_action :authenticate_registered_user!, :clear_flash
  before_action :show_progress_bar, only: :show
  before_action :track_events, only: :show
  helper_method :module_item, :training_module, :note

  def index
    first_module_item = ModuleItem.find_by(training_module: training_module_name)
    redirect_to training_module_content_page_path(training_module_name, first_module_item)
  end

  def show
    @module_progress = helpers.module_progress(training_module)
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

  def show_progress_bar
    @module_progress_bar = ModuleProgressBarDecorator.new(helpers.module_progress(training_module))
  end

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

  # - create 'module_content_page' for every page view
  # - create 'module_start' once the intro is viewed
  # - create 'module_complete' once the certificate is viewed
  # - create 'confidence_check_complete' once the last question is submitted
  #
  # - recalculate the user's progress state as a module is started/completed
  #
  def track_events
    track('module_content_page', type: module_item.type)

    if track_module_start?
      track('module_start')
      helpers.calculate_module_state
    elsif track_confidence_check_complete?
      track('confidence_check_complete')
    elsif track_module_complete?
      track('module_complete')
      helpers.calculate_module_state
    end
  end

  # Check current item type for matching named event ---------------------------

  # @return [Boolean]
  def track_module_start?
    module_item.submodule_intro? && module_start_untracked?
  end

  # @return [Boolean]
  def track_module_complete?
    module_item.certificate? && module_complete_untracked?
  end

  # @return [Boolean]
  def track_confidence_check_complete?
    module_item.thankyou? && confidence_complete_untracked?
  end

  # Check unique event is not already present ----------------------------------

  # @return [Boolean]
  def confidence_complete_untracked?
    untracked?('confidence_check_complete', training_module_id: training_module_name)
  end

  # @return [Boolean]
  def module_complete_untracked?
    return false if module_start_untracked?

    untracked?('module_complete', training_module_id: training_module_name)
  end

  # @return [Boolean]
  def module_start_untracked?
    untracked?('module_start', training_module_id: training_module_name)
  end
end
