class Registration::SettingTypeOthersController < Registration::BaseController
  def edit
    @user_form = Users::SettingTypeOtherForm.new(user: current_user)
  end

  def update
    @user_form = Users::SettingTypeOtherForm.new(user_params.merge(user: current_user))

    if @user_form.save
      redirect_to next_action { edit_registration_local_authority_path }
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:setting_type_other)
  end
end
