module Registration
  class SettingTypeOthersController < BaseController
    def edit; end

    def update
      form.setting_type_other = user_params[:setting_type_other]

      if form.save
        setting = form.setting_type
        user = current_user

        track('user_setting_type_other_change', success: true)

        if setting.local_authority? && user.local_authority.blank?
          redirect_to edit_registration_local_authority_path
        else
          redirect_to edit_registration_role_type_path
        end
      else
        track('user_setting_type_other_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:setting_type_other)
    end

    # @return [Registration::SettingTypeOtherForm]
    def form
      @form ||=
        SettingTypeOtherForm.new(
          user: current_user,
          setting_type_other: current_user.setting_type_other,
        )
    end
  end
end
