class Training::PagesController < Training::BaseController

  # TODO: retire these helpers
  helper_method :module_item, :training_module, :note

  # TODO: replace with these helpers
  helper_method :mod

  def index
    redirect_to training_module_content_page_path(mod_name, 'what-to-expect')
  end

  def show
    if question
      redirect_to training_module_questionnaire_path(mod_name, question.name)
    elsif module_item.assessment_results?
      redirect_to training_module_assessment_result_path(mod_name, module_item.name)
    else
      @module_progress = ContentfulModuleOverviewDecorator.new(progress)
      @module_progress_bar = ContentfulModuleProgressBarDecorator.new(progress)

      @module_item = @model = module_item

      render_page
    end
  end

private

  # ----------------------------------------------------------------------------

  # @return [String] for redirect
  def mod_name
    params[:training_module_id]
  end

  # @return [Training::Module] shallow
  def mod
    @mod ||= Training::Module.by_name(mod_name)
  end

  def training_module
    mod
  end

  # @return [Training::Page, Training::Video]
  def module_item
    @module_item ||= page || video
  end

  def content_page
    module_item
  end

  # ----------------------------------------------------------------------------

  def progress
    @progress ||= helpers.cms_module_progress(mod)
  end

  def render_page
    render module_item.page_type
  rescue ActionView::MissingTemplate
    render 'text_page'
  end

  # ----------------------------------------------------------------------------

  def track_events
    track('module_content_page')

    if track_module_start?
      track('module_start')
      helpers.calculate_module_state
    end

    if module_item.assessment_results? && module_complete_untracked?
      track('module_complete')
      helpers.calculate_module_state
    end

    track('confidence_check_complete') if track_confidence_check_complete?
  end

  # @return [Boolean]
  def track_module_start?
    module_item.module_intro? && untracked?('module_start', training_module_id: mod_name)
  end

  # @return [Boolean]
  def track_confidence_check_complete?
    helpers.module_progress(module_item.parent).completed? && untracked?('confidence_check_complete', training_module_id: mod_name)
  end

  # @return [Boolean]
  def module_complete_untracked?
    return false if untracked?('module_start', training_module_id: mod_name)

    untracked?('module_complete', training_module_id: mod_name)
  end

  # ----------------------------------------------------------------------------

  # @return [Training::Question]
  def question
    Training::Question.load_children(0).find_by(name: params[:id], training_module: { name: mod_name }).first
    # Training::Question.by_name(mod_name: mod_name, page_name: page_name)
  end

  # @return [Training::Page]
  def page
    Training::Page.load_children(0).find_by(name: params[:id], training_module: { name: mod_name }).first
    # Training::Page.by_name(mod_name: mod_name, page_name: page_name)
  end

  # @return [Training::Video]
  def video
    Training::Video.load_children(0).find_by(name: params[:id], training_module: { name: mod_name }).first
    # Training::Video.by_name(mod_name: mod_name, page_name: page_name)
  end
end
