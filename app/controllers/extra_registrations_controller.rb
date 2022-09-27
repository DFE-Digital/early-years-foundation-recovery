# Registration is completed in a number of steps.
#
# Each steps has:
#   - a partial (that displays the form elements for the step)
#   - a form object (that defines validations rules and save options)
#
class ExtraRegistrationsController < ApplicationController
  # @return [Hash] partial => form object class
  STEP_FORMS = {
    name: Users::NameForm,
    setting: Users::SettingForm,
  }.freeze

  # @return [Array<Symbol>]
  #
  STEPS = STEP_FORMS.keys.freeze

  before_action :authenticate_user!

  def index
    redirect_to edit_extra_registration_path(STEPS.first)
  end

  def edit
    @user_form = current_form_klass.new(user: current_user)
  end

  def update
    @user_form = current_form_klass.new(user_params.merge(user: current_user))
    return render(:edit) unless @user_form.save

    if next_step
      redirect_to edit_extra_registration_path(next_step)
    else
      track('user_registration', success: true)
      current_user.update! registration_complete: true
      redirect_to my_modules_path, notice: t(:complete, scope: :extra_registration)
    end
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number, :setting_type, :setting_type_other)
  end

  # @return [Symbol]
  def next_step
    return if STEPS.last == current_step

    index = STEPS.index(current_step)
    STEPS[index + 1]
  end

  # @return [Symbol]
  def current_step
    @current_step ||= params[:id].to_sym
  end
  helper_method :current_step

  # @return [NameForm, SettingForm]
  def current_form_klass
    @current_form_klass ||= STEP_FORMS[current_step]
  end
end
