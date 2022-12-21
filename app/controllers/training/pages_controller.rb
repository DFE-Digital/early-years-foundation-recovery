class Training::PagesController < ApplicationController
  def index
    redirect_to training_module_content_page_path(params[:module_id], 'what-to-expect')
  end

  def show
    redirect_to training_module_questionnaire_path(params[:module_id], params[:id])
  end
end