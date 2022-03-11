class QuestionnairesController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    questionnaire
  end

  def update
    questionnaire.errors.clear
    update_questionnaire
    if results.values.all?(true)
      redirect_to training_module_content_page_path(training_module, next_module_item)
    else
      generate_error_messages
      render :show, status: :unprocessable_entity
    end
  end

  private

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: params[:id], training_module: training_module)
  end

  def next_module_item
    current_module_item = ModuleItem.find_by(training_module: training_module, name: questionnaire.name)
    current_module_item.next_item
  end

  def update_questionnaire
    questionnaire_params.each do |key, value|
      value.select!(&:present?) if value.is_a?(Array) # Remove spurious empty entry created by form
      questionnaire.send("#{key}=", value)
    end
  end

  # Check how submitted answers match defined correct answers
  def results
    questionnaire_params
    @results ||= questionnaire.questions.each_with_object({}) do |(question, data), result|
      # Put into an array and then flattened so single and multi-choice questions can be handled in the same way
      result[question] = [questionnaire_params[question]].flatten.select(&:present?) == data[:correct_answers]
    end
  end

  def generate_error_messages
    results.map do |question, result|
      questionnaire.errors.add question, "is#{ ' not' unless result } correct"
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
      data[:multi_select] ? {question => []} : question
    end
  end
end
