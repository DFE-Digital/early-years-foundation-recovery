class Training::ContentPagesController < Training::BaseController
  helper_method :module_item, :training_module, :note

  def show
    @model = Training::Page.find_by(module_id: page_params[:module_id], slug: page_params[:id]).load.first
    @module_item = @model

    render_page
  end

private

  def page_params
    params.permit(:module_id, :id)
  end

  def training_module
    module_item.parent
  end

  def note
    @note ||= current_user.notes.where(training_module: training_module_name, name: page_params[:id]).first_or_initialize(title: @model.heading)
  end

  def training_module_name
    @training_module_name ||= page_params[:module_id]
  end

  def render_page
    render @model.component
  rescue ActionView::MissingTemplate
    render 'text_page'
  end
end
