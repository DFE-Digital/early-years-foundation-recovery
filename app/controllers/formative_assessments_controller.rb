class FormativeAssessmentsController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate_questionnaire(existing_answers.to_h.symbolize_keys) if existing_answers.present?
  end

  def update
    archive_previous_user_answers
    if questionnaire_params.values.all?(&:present?)
      populate_questionnaire(questionnaire_params)
      save_answers
      flash[:alert] = nil
    else
      flash[:alert] = 'Please select an answer'
    end
    render :show, status: :unprocessable_entity
  end

private

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: params[:id], training_module: training_module)
  end

  def training_module
    @training_module ||= params[:training_module_id]
  end

  def questionnaire_params
    @questionnaire_params ||= params.require(:questionnaire).permit(permitted_methods)
  end

  # An attribute is permitted if it is defined in the questionnaire's YAML data
  # Added complication because multi-choice questions need to be set as hash within `permit` call
  # as they are submitted as an array within params
  def permitted_methods
    questionnaire.questions.map do |question, data|
      data[:multi_select] ? { question => [] } : question
    end
  end

  def populate_questionnaire(question_input)
    return if question_input.empty?

    questionnaire.question_list.each do |question|
      answer = [question_input[question.name]].flatten.select(&:present?)
      question.set_answer(answer: answer)
    end
    questionnaire.submitted = true
  end

  def archive_previous_user_answers
    existing_user_answers.update_all(archived: true)
  end

  def existing_user_answers
    current_user.user_answers.not_archived.where(questionnaire_id: questionnaire.id)
  end

  def save_answers
    questionnaire.questions.each do |question, data|
      answer = Array(questionnaire.send(question))
      next if answer.empty?

      current_user.user_answers.create!(
        questionnaire_id: questionnaire.id,
        question: question,
        answer: answer,
        correct: answer == data[:correct_answers].map(&:to_sym),
      )
    end
  end
end
