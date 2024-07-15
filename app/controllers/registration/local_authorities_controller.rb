module Registration
  class LocalAuthoritiesController < BaseController
    def edit; end

    def update
      form.local_authority = user_params[:local_authority]

      if form.save
        track('user_local_authority_change', success: true)
        redirect_to next_form_path
      else
        track('user_local_authority_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:local_authority)
    end

    # @return [String]
    def next_form_path
      if form.setting_type.has_role?
        edit_registration_role_type_path
      else
        edit_registration_training_emails_path
      end
    end

    # @return [Registration::LocalAuthorityForm]
    def form
      @form ||=
        LocalAuthorityForm.new(
          user: current_user,
          setting_type_id: current_user.setting_type_id,
          local_authority: current_user.local_authority,
        )
    end
  end
end
