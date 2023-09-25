module Registration
  class SettingTypesController < BaseController
    def edit; end

    def update
      form.setting_type_id = user_params[:setting_type_id]

      if form.save
        if form.setting_type.local_authority?
          redirect_to edit_registration_local_authority_path
        elsif current_user.registration_complete?
          redirect_to user_path, notice: t(:details_updated)
        else
          redirect_to edit_registration_training_emails_path
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def user_params
      params.require(:user).permit(:setting_type_id)
    end

    # @return [Registration::SettingTypeForm]
    def form
      @form ||= SettingTypeForm.new(user: current_user, setting_type_id: current_user.setting_type_id)
    end
  end
end
