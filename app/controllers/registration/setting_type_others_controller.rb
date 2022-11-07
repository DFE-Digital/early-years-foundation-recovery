class Registration::SettingTypeOthersController < Registration::BaseController
  def edit
    @user_form = Users::SettingTypeOtherForm.new(user: current_user, setting_type_other: current_user.setting_type_other)
  end

  def update
    @user_form = Users::SettingTypeOtherForm.new(user_params.merge(user: current_user))

    if @user_form.save
      redirect_to edit_registration_local_authority_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:setting_type_other)
  end
end
