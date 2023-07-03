class Registration::TrainingEmailsController < Registration::BaseController
  def edit
    @user_form = Users::TrainingEmailsForm.new(user: current_user, training_emails: current_user.training_emails)
  end

  def update
    @user_form = Users::TrainingEmailsForm.new(user_params.merge(user: current_user))

    if @user_form.save
      redirect_to edit_registration_early_years_emails_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:training_emails)
  end
end
