class Training::ContentPagesController < Training::BaseController
  before_action :authenticate_registered_user!, :clear_flash
  helper_method :model, :training_module, :note, :module_item
  after_action :track_events, only: :show

  def show
    if model.component == 'formative_questionnaire'
      redirect_to training_module_questionnaire_path(training_module_name, module_item.slug)
    elsif model.assessment_results?
      redirect_to training_module_assessment_result_path(training_module_name, module_item)
    else
      begin
        render model.component
      rescue ActionView::MissingTemplate
        render 'text_page'
      end
    end
  end

private

  def model
    @model ||= Training::Page.find_by(module_id: page_params[:module_id], slug: page_params[:id]).load.first
  end
  alias_method :module_item, :model
  
  def page_params
    params.permit(:module_id, :id)
  end

  def training_module
    model.parent
  end

  def note
    @note ||= current_user.notes.where(training_module: training_module_name, name: page_params[:id]).first_or_initialize(title: @model.heading)
  end

  def training_module_name
    @training_module_name ||= page_params[:module_id]
  end
end