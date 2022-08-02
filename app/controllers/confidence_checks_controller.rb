class ConfidenceChecksController < ApplicationController
  include AssessmentQuestions
  include ApplicationHelper
  before_action :authenticate_registered_user!

  def show
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
    quiz = AssessmentQuiz.new(user: current_user, type: 'confidence_check', training_module_id: params[:training_module_id], name: params[:id])
    if params[:id] == quiz.assessment_first_page.name && !tracked?('confidence_check_start', training_module_id: params[:training_module_id])
      track('confidence_check_start')
    end
  end

  def update
    archive_previous_user_answers
    if validate_param_empty
      populate_questionnaire(questionnaire_params)
      save_answers
      flash[:error] = nil
      link_to_next_module_item_from_controller(questionnaire.module_item)
      track('questionnaire_answer', success: true, type: 'confidence_check', questionnaire_id: params[:id])
      return
    else
      flash[:error] = 'Please select an answer'
    end
    render :show, status: :unprocessable_entity and return
  end
end
