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
    if result.check_if_assessment_taken && !tracked?('summative_assessment_complete', training_module_id: params[:training_module_id], questionnaire_id: params[:id])
      track('summative_assessment_complete', success: true, type: 'summative_assessment', score: result.percentage_of_assessment_answers_correct, training_module_id: params[:training_module_id], questionnaire_id: params[:id])
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
