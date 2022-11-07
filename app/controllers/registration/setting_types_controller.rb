class Registration::SettingTypesController < Registration::BaseController
  def edit
    @user_form = Users::SettingTypeForm.new(user: current_user, setting_type_id: current_user.setting_type_id)
  end

  def update
    @user_form = Users::SettingTypeForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if @user_form.local_authority_next?
        redirect_to edit_registration_local_authority_path
      else
        complete_registration
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:setting_type_id)
  end
end
