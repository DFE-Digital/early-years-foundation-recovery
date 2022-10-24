class Registration::SettingTypesController < Registration::BaseController
  def edit
    @user_form = Users::SettingForm.new(user: current_user)
  end

  def update
    @user_form = Users::SettingForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if local_authority_next?
        redirect_to(next_action { edit_registration_local_authority_path })
      elsif role_types_next?
        redirect_to(next_action { edit_registration_role_type_apth })
      else
        complete_registration
      end
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:setting_type_id)
  end

  def setting
    @setting ||= SettingType.find user_params[:setting_type_id]
  end

  def local_authority_next?
    setting.local_authority?
  end

  def role_types_next?
    setting.role_type != 'none'
  end
end
