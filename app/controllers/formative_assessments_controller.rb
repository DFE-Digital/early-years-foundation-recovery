class FormativeAssessmentsController < ApplicationController
  include AssessmentQuestions
  before_action :authenticate_registered_user!

  def show
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
  end

  def update
    archive_previous_user_answers
    puts 'params.inspect'
    puts validate_params
    puts 'params.inspect'
    if params.key?(:questionnaire)
      process_questionaire
    else
      puts 'Please select an answer'
      flash[:alert] = 'Please select an answer'
    end
    render :show, status: :unprocessable_entity
  end

  private

  def validate_params
    multi = 'multi_select'

    puts 'questionnaire.questions[0][:multi_select]'
    
    puts questionnaire.question.inspect
    puts 'questionnaire.questions[0][:multi_select]'
    if params.key?(:questionnaire)
    end
  end
end
