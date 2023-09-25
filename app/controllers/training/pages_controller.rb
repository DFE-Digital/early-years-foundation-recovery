class Training::PagesController < ApplicationController
  include Learning

  before_action :authenticate_registered_user!
  before_action :track_events, only: :show

  helper_method :mod,
                :content,
                :progress_bar,
                :module_progress,
                :note

  include Learning

  def index
    redirect_to training_module_page_path(mod_name, 'what-to-expect')
  end

  def show
    if content.is_question?
      redirect_to training_module_question_path(mod.name, content.name)
    elsif content.assessment_results?
      redirect_to training_module_assessment_path(mod.name, content.name)
    else
      render_page
    end
  end

private

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
    track('module_content_page')

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

  # @see Tracking
  # @return [Hash]
  def tracking_properties
    { type: content.page_type, uid: content.id, mod_uid: mod.id }
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
