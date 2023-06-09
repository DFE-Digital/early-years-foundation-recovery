class Registration::DfeEmailOptInsController < Registration::BaseController
  def edit
    @user_form = Users::DfeEmailOptInForm.new(user: current_user, dfe_email_opt_in: current_user.dfe_email_opt_in)
  end

  def update
    @user_form = Users::DfeEmailOptInForm.new(user_params.merge(user: current_user))

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
    params.require(:user).permit(:dfe_email_opt_in)
  end
end
