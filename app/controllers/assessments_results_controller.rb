class AssessmentsResultsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_registered_user!
  before_action :clear_flash

  def show
    quiz
    @quiz.save_user_assessment unless @quiz.check_if_saved_result
    module_item
    @module_item.model
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
