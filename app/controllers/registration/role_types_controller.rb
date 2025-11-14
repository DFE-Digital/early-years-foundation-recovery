module Registration
  class RoleTypesController < BaseController
    def edit; end

    def update
      form.role_type = user_params[:role_type]

      if form.save
        track('user_role_type_change', success: true)
        flash[:important] = complete_registration_banner if returning_user?
        redirect_to edit_registration_early_years_experience_path
      else
        track('user_role_type_change', success: false)
        flash[:important] = complete_registration_banner if returning_user?
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:role_type)
    end

    # @return [Registration::RoleTypeForm]
    def form
      @form ||=
        RoleTypeForm.new(
          user: current_user,
          role_type: current_user.role_type,
        )
    end
  end
end
