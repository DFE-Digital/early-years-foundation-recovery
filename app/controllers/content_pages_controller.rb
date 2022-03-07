class ContentPagesController < ApplicationController
  def show
    @model = module_item.model

    if @model.is_a?(Questionnaire)
      redirect_to @model
    else
      render module_item.type
    end
  end

  private

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, id: params[:id])
  end

  def training_module
    params[:training_module_id]
  end
end
