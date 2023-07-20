class Registration::TrainingEmailsController < Registration::BaseController
  def edit
    @user_form = Users::TrainingEmailsForm.new(user: current_user, training_emails: current_user.training_emails)
  end

  def update
    @user_form = Users::TrainingEmailsForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to my_modules_path, notice: t('.complete_update')
      else
        complete_registration
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:training_emails)
  end
end
