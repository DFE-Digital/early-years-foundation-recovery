class QuestionnairesController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :archive_previous_user_answers, only: [:update]

  def show
    @user_answers = existing_user_answers
    update_questionnaire if @user_answers.present?
    questionnaire
  end

  def update
    questionnaire.errors.clear
    update_questionnaire

    if questionnaire.valid?
      redirect_to training_module_content_page_path(training_module, next_module_item)
    else
      render :show, status: :unprocessable_entity
    end
  end

private

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: params[:id], training_module: training_module)
  end

  def next_module_item
    questionnaire.module_item.next_item
  end

  def update_questionnaire
    user_answers.each do |user_answer|
      answer = questionnaire.questions[user_answer.question.to_sym][:multi_select] ? user_answer.answer : user_answer.answer.first
      questionnaire.send("#{user_answer.question}=", answer)
    end
  end

  def user_answers
    @user_answers ||= questionnaire.questions.map do |question, data|
      # Put into an array and then flattened so single and multi-choice questions can be handled in the same way
      answer = [questionnaire_params[question]].flatten.select(&:present?)
      current_user.user_answers.create!(
        questionnaire_id: questionnaire.id,
        question: question,
        answer: answer,
        correct: answer == data[:correct_answers],
      )
    end
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

  def archive_previous_user_answers
    existing_user_answers.update_all(archived: true)
  end

  # change this to where module and name as ids are auto generated
  def existing_user_answers
    current_user.user_answers.not_archived.where(questionnaire_id: questionnaire.id)
  end
end
