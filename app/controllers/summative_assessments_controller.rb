class SummativeAssessmentsController < ApplicationController
  include AssessmentQuestions
  before_action :authenticate_registered_user!

  def show
    puts @module_item.inspect
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
  end

  def update
    archive_previous_user_answers
    if params.key?(:questionnaire)
      process_questionaire
    else
      flash[:alert] = 'Please select an answer'
    end
    render :show, status: :unprocessable_entity
  end
end
