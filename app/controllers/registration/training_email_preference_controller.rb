class Registration::TrainingEmailPreferenceController < Registration::BaseController
  def edit
    @user_form = Users::TrainingEmailPreferenceForm.new(user: current_user, training_email_opt_in: current_user.training_email_opt_in)
  end

  def update
    @user_form = Users::TrainingEmailPreferenceForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: t('.complete_update')
      else
        redirect_to edit_registration_setting_type_path
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:training_email_opt_in)
  end
end