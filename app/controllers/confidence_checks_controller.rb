class ConfidenceChecksController < ApplicationController
  include AssessmentQuestions
  include ApplicationHelper
  before_action :authenticate_registered_user!

  def show
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
    quiz = AssessmentQuiz.new(user: current_user, type: 'confidence_check', training_module_id: params[:training_module_id], name: params[:id])
    event = Ahoy::Event.where(user_id: current_user, name: 'confidence_questionnaire_start').where_properties(training_module_id: params[:training_module_id])
    if params[:id] == quiz.assessment_first_page.name && !event.exists?
      track('confidence_questionnaire_start')
    end
  end

  def update
    archive_previous_user_answers
    if validate_param_empty
      populate_questionnaire(questionnaire_params)
      save_answers
      flash[:error] = nil
      link_to_next_module_item_from_controller(questionnaire.module_item)
      track('questionnaire_answer')
      return
    else
      flash[:error] = 'Please select an answer'
    end
    render :show, status: :unprocessable_entity and return
  end
end
