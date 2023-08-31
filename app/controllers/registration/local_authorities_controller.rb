module Registration
  class LocalAuthoritiesController < BaseController
    def edit; end

    def update
      form.local_authority = user_params[:local_authority]

      if form.save
        redirect_to next_form_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    # @return [Hash]
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
