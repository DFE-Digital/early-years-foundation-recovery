class AssessmentsResultsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_registered_user!
  before_action :clear_flash
  attr_accessor :percentage_of_answers_correct


  def show
    quiz
    module_item
    model_assessment = @module_item.model
    puts '@module_item.model.inspect'
    puts model_assessment.heading
    puts '@module_item.model.inspect'
    
  end

  private

  def quiz
    @quiz = AssessmentQuiz.new(user: current_user, type: 'summative', training_module_id: params[:training_module_id], name: params[:id] )
  end

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: params[:training_module_id], name: params[:id])
  end
end
