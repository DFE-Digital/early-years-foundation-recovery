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
end