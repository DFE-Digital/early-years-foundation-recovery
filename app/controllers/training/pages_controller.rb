class Training::PagesController < Contentful::BaseController
  # TODO: retire these helpers
  helper_method :module_item, :training_module, :note

  # TODO: replace with these helpers
  helper_method :mod, :content

  def index
    redirect_to training_module_content_page_path(mod_name, 'what-to-expect')
  end

  def show
    if content.is_question?
      redirect_to training_module_questionnaire_path(mod_name, content.name)
    elsif module_item.assessment_results?
      redirect_to training_module_assessment_result_path(mod_name, content.name)
    else
      @module_progress = ContentfulModuleOverviewDecorator.new(progress)
      @module_progress_bar = ContentfulModuleProgressBarDecorator.new(progress)

      @model = content # TODO: deprecate this instance variable

      render_page
    end
  end

private

  # TODO: deprecate these ------------------------------------------------------

  def training_module
    mod
  end

  def module_item
    @module_item ||= content
  end

  # ----------------------------------------------------------------------------

  # @return [String]
  def mod_name
    params[:training_module_id]
  end

  # @return [String]
  def content_slug
    params[:id]
  end

  # @return [Training::Module] shallow
  def mod
    @mod ||= Training::Module.by_name(mod_name)
  end

  # @return [Training::Content]
  def content
    @content ||= mod.page_by_name(content_slug)
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
end
