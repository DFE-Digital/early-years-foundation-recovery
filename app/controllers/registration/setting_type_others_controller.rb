class Registration::SettingTypeOthersController < Registration::BaseController
  def edit; end

  def update
    form.setting_type_other = user_params[:setting_type_other]

    if form.save
      redirect_to edit_registration_local_authority_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:setting_type_other)
  end

  # @return [Users::SettingTypeOtherForm]
  def form
    @form ||= Users::SettingTypeOtherForm.new(user: current_user, setting_type_other: current_user.setting_type_other)
  end
end
