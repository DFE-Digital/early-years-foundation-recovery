module Registration
  class RoleTypeOthersController < BaseController
    def edit; end

    def update
      form.role_type_other = user_params[:role_type_other]

      if form.save
        track('user_role_type_other_change', success: true)
        flash[:important] = complete_registration_banner
        redirect_to edit_registration_early_years_experience_path
      else
        track('user_role_type_other_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:role_type_other)
    end

    # @return [Registration::RoleTypeOtherForm]
    def form
      @form ||=
        RoleTypeOtherForm.new(
          user: current_user,
          role_type_other: current_user.role_type_other,
        )
    end
  end
end
