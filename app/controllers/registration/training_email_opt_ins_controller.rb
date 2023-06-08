class Registration::TrainingEmailOptInsController < Registration::BaseController

  @options = [
    OpenStruct.new(id: true, name: 'oui'),
    OpenStruct.new(id: false, name: 'non')
  ]

  def edit
    @user_form = Users::TrainingEmailOptInsForm.new(user: current_user, training_email_opt_in: current_user.training_email_opt_in)
  end

  def update
    @user_form = Users::TrainingEmailOptInsForm.new(user_params.merge(user: current_user))

    if @user_form.save
        redirect_to edit_registration_dfe_email_opt_in_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:training_email_opt_in)
  end
end