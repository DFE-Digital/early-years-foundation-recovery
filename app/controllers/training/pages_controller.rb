class Training::PagesController < Training::BaseController
  helper_method :module_item, :training_module, :note

  def index
    first_module_item = training_module.pages.first
    redirect_to training_module_content_page_path(params[:training_module_id], first_module_item.name)
  end

  def show
    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(training_module))
    @module_progress_bar = ModuleProgressBarDecorator.new(helpers.module_progress(training_module))
    @module_item = @model = module_item

    if @model.is_a?(Training::Question)
      redirect_to training_module_questionnaire_path(training_module.name, module_item.name)
    elsif module_item.assessment_results?
      redirect_to training_module_assessment_result_path(training_module.name, module_item.name)
    else
      render_page
    end
  end

private

  def render_page
    render module_item.page_type
  rescue ActionView::MissingTemplate
    render 'text_page'
  end

  def training_module
    Training::Module.find_by(name: params[:training_module_id]).first
  end

  def module_item
    page || question || video
  end

  def page
    Training::Page.find_by(name: params[:id], trainingModule: params[:training_module_id]).first
  end

  def question
    Training::Question.find_by(name: params[:id], trainingModule: params[:training_module_id]).first
  end

  def video
    Training::Video.find_by(name: params[:id], trainingModule: params[:training_module_id]).first
  end
  
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
    module_item.module_intro? && untracked?('module_start', training_module_id: training_module_name)
  end

  # @return [Boolean]
  def track_confidence_check_complete?
    helpers.module_progress(module_item.parent).completed? && untracked?('confidence_check_complete', training_module_id: training_module_name)
  end

  def module_complete_untracked?
    return false if untracked?('module_start', training_module_id: training_module.name)

    untracked?('module_complete', training_module_id: training_module.name)
  end
end
