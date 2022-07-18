class FormativeAssessmentsController < ApplicationController
  include AssessmentQuestions
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
      flash[:error] = nil
    else
      flash[:error] = 'Please select an answer'
    end

    render :show, status: :unprocessable_entity
  end
end
