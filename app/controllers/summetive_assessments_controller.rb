class SummetiveAssessmentsController < ApplicationController
  include QuestionsService
  before_action :authenticate_registered_user!

  def show
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

  def results
    summative_questions = summative_questions(params['training_module_id'])
    question_lists = questions_key(summative_questions)
    user_answers = users_answered_questions(question_lists)
    d = merge_summative_users_answers(summative_questions, user_answers)
    # puts 'd.inspect'
    # puts d.inspect
    # puts 'd.inspect'
  end
end
