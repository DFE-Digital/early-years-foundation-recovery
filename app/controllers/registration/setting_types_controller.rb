module Registration
  class SettingTypesController < BaseController
    def edit; end

    def update
      form.setting_type_id = user_params[:setting_type_id]

      if form.save
        track('user_setting_type_change', success: true)
        if england_selected? && form.setting_type.local_authority?
          redirect_to edit_registration_local_authority_path
        elsif !england_selected?
          redirect_to edit_registration_role_type_path
        elsif current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          redirect_to edit_registration_training_emails_path
        end
      else
        track('user_setting_type_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:setting_type_id)
    end

    # @return [Registration::SettingTypeForm]
    def form
      @form ||=
        SettingTypeForm.new(
          user: current_user,
          setting_type_id: current_user.setting_type_id,
        )
    end

    # @return [Boolean]
    def england_selected?
      country = current_user.country.to_s
      country.blank? || country.casecmp('England').zero?
    end
  end
end
