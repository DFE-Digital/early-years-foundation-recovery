class Training::PagesController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :track_events, only: :show

  helper_method :mod,
                :content,
                :progress_bar,
                :module_progress,
                :note

  def index
    redirect_to training_module_content_page_path(mod_name, 'what-to-expect')
  end

  def show
    if content.is_question?
      redirect_to training_module_questionnaire_path(mod.name, content.name)
    elsif content.assessment_results?
      redirect_to training_module_assessment_result_path(mod.name, content.name)
    else
      # TODO: deprecate these instance variables
      @model = content
      @module_item = content

      render_page
    end
  end

private

  # @return [String]
  def mod_name
    params[:training_module_id]
  end

  # @return [String]
  def content_name
    params[:id]
  end

  # @return [Training::Module]
  def mod
    Training::Module.by_name(mod_name)
  end

  # @return [Training::Page, Training::Video, Training::Question]
  def content
    mod.page_by_name(content_name)
  end

  def module_progress
    ContentfulModuleOverviewDecorator.new(progress)
  end

  def progress_bar
    ContentfulModuleProgressBarDecorator.new(progress)
  end

  def progress
    helpers.cms_module_progress(mod)
  end

  # ----------------------------------------------------------------------------

  def note
    current_user
      .notes
      .where(training_module: mod.name, name: content.name)
      .first_or_initialize(title: content.heading)
  end

  def render_page
    render content.page_type
  rescue ActionView::MissingTemplate
    render 'text_page'
  end

  # - create 'module_content_page' for every page view
  # - create 'module_start' once the intro is viewed
  # - create 'module_complete' once the certificate is viewed
  # - create 'confidence_check_complete' once the last question is submitted
  #
  # - recalculate the user's progress state as a module is started/completed
  #
  def track_events
    track('module_content_page', type: content.page_type, cms: true)

    if track_module_start?
      track('module_start', cms: true)
      helpers.calculate_module_state
    elsif track_confidence_check_complete?
      track('confidence_check_complete', cms: true)
    elsif track_module_complete?
      track('module_complete', cms: true)
      helpers.calculate_module_state
    end
  end

  # @return [Boolean]
  def track_module_complete?
    content.certificate? && module_complete_untracked?
  end

  # @return [Boolean]
  def track_module_start?
    content.submodule_intro? && untracked?('module_start', training_module_id: mod.name)
  end

  # @return [Boolean]
  def track_confidence_check_complete?
    content.thankyou? && untracked?('confidence_check_complete', training_module_id: mod.name)
  end

  # @return [Boolean]
  def module_complete_untracked?
    return false if untracked?('module_start', training_module_id: mod.name)

    untracked?('module_complete', training_module_id: mod.name)
  end
end
