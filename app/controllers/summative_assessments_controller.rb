class SummativeAssessmentsController < ApplicationController
  include AssessmentQuestions
  before_action :authenticate_registered_user!

  def show

    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
  end

  def update
    archive_previous_user_answers
    if params.key?(:questionnaire)
      process_summative_questionaire
    else
      flash[:alert] = 'Please select an answer'
    end

     render :show, status: :unprocessable_entity
  end

  private

  def process_summative_questionaire
    if questionnaire_params.values.all?(&:present?)
      populate_questionnaire(questionnaire_params)
      save_answers
      flash[:alert] = nil
      # redirect_to training_module_content_page_path(@questionnaire.module_item.training_module, @questionnaire.module_item)
    else
      flash[:alert] = 'Please select an answer'
    end
  end

end
