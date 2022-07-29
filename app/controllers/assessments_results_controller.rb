class AssessmentsResultsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_registered_user!
  before_action :clear_flash

  def show
    quiz
    @quiz.save_user_assessment unless @quiz.check_if_saved_result
    module_item
    @module_item.model
    result = AssessmentQuiz.new(user: current_user, type: 'summative_assessment', training_module_id: params[:training_module_id], name: params[:id])
    event = Ahoy::Event.where(user_id: current_user, name: 'summative_assessment_complete').where_properties(training_module_id: params[:training_module_id])
    if result.check_if_assessment_taken && !event.exists?
      track('summative_assessment_complete')
    end
  end

  def retake_quiz
    quiz
    @quiz.archive_previous_user_assessment_answers
    redirect_to training_module_content_page_path(params[:training_module_id], @quiz.assessment_intro_page)
  end

private

  def quiz
    @quiz = AssessmentQuiz.new(user: current_user, type: 'summative_assessment', training_module_id: params[:training_module_id], name: params[:id])
  end

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: params[:training_module_id], name: params[:id])
  end
end
