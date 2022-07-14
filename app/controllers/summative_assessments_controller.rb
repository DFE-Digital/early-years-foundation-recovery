class SummativeAssessmentsController < ApplicationController
  include AssessmentQuestions
  include ApplicationHelper
  before_action :authenticate_registered_user!

  def show
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
  end

  def update
    archive_previous_user_answers
    if validate_param_empty
      populate_questionnaire(questionnaire_params)
      save_answers
      flash[:alert] = nil
      link_to_next_module_item_from_controller(questionnaire.module_item)
      return
    else
      flash[:error] = 'Please select an answer'
    end

    render :show, status: :unprocessable_entity and return
  end
end
