class ExtraRegistrationsController < ApplicationController
  # Registration is completed in a number of steps.
  # Each steps has a partial (that displays the form elements for the step),
  # and a form object (that defines validations rules and save options).
  STEP_FORMS = {
    # partial => form object class
    name: Users::NameForm,
    setting: Users::SettingForm,
  }.freeze
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
      current_user.update! registration_complete: true
      redirect_to root_path, notice: 'Registration complete'
    end
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number)
  end

  def next_step
    return if STEPS.last == current_step

    index = STEPS.index(current_step)
    STEPS[index + 1]
  end

  def current_step
    @current_step ||= params[:id].to_sym
  end
  helper_method :current_step

  def current_form_klass
    @current_form_klass ||= STEP_FORMS[current_step]
  end
end
