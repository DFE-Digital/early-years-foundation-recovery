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
    when 'summetive_assessment'
      training_module_summetive_assessment_path(training_module, module_item.model)
    when 'summetive_assessment_result'
      training_module_summetive_assessment_results_path(training_module, module_item.model)
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
