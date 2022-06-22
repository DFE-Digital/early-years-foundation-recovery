class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :reload_yaml if Rails.env.development?
  default_form_builder(EarlyYearsRecoveryFormBuilder)

  def authenticate_registered_user!
    authenticate_user! unless user_signed_in?
    return true if current_user.registration_complete?

    redirect_to extra_registrations_path, notice: 'Please complete registration'
  end

  def questionnaire_path(training_module, module_item)
    case module_item.type
    when 'formative_assessment'
      training_module_formative_assessment_path(training_module, module_item.model)
    when 'summative_assessment'
      training_module_summative_assessment_path(training_module, module_item.model)
    when 'confidence_check'
      training_module_confidence_check_path(training_module, module_item.model)
    when 'assessments_results'
      training_module_assessments_result_path(training_module, module_item)
    else
      training_module_questionnaire_path(training_module, module_item.model)
    end
  end

  def configure_permitted_parameters
    update_attrs = %i[password password_confirmation current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  def reload_yaml
    [QuestionnaireData, SummativeQuestionnaire ].each { |m| m.reload(true) }
  end

end
