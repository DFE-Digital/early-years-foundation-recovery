class QuestionnairesController < ApplicationController
  def show
    questionnaire
  end

  def update
    questionnaire.errors.clear
    update_questionnaire
    if results.values.all?(true)
      # TODO: redirect to next step
      render :show, status: :unprocessable_entity # status set to force page reload
    else
      generate_error_messages
      render :show, status: :unprocessable_entity
    end
  end

  private

  def questionnaire
    @questionnaire ||= Questionnaire.find_by(name: params[:id])
  end

  def update_questionnaire
    questionnaire_params.each do |key, value|
      value.select!(&:present?) if value.is_a?(Array) # Remove spurious empty entry created by form
      questionnaire.send("#{key}=", value)
    end
  end

  # Check how submitted answers match correct answers
  def results
    questionnaire_params
    @results ||= questionnaire.questions.each_with_object({}) do |(question, data), result|
      # Put into an array and then flattened so single and multi-choice questions can be handled in the same way
      result[question] = [questionnaire_params[question]].flatten.select(&:present?) == data[:correct_answers]
    end
  end

  def generate_error_messages
    results.map do |question, result|
      questionnaire.errors.add question, "is #{' not' unless result} correct"
    end
  end

  def questionnaire_params
    @questionnaire_params ||= params.require(:questionnaire).permit(permitted_methods)
  end

  # An attribute is permitted if it is defined in the questionnaire's YAML data
  # Added complication because multi-choice questions need to be set as hash within `permit` call
  # as they are submitted as an array within params
  def permitted_methods
    questionnaire.questions.map do |question, data|
      data[:multi_select] ? {question => []} : question
    end
  end
end
