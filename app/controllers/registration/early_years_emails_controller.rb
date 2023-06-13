class Registration::EarlyYearsEmailsController < Registration::BaseController
  def edit
    @user_form = Users::DfeEmailsForm.new(user: current_user, early_years_emails: current_user.early_years_emails)
  end

  def update
    @user_form = Users::DfeEmailsForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: t('.complete_update')
      else
        complete_registration
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:early_years_emails)
  end
end
