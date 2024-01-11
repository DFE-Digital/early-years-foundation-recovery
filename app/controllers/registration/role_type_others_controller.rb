module Registration
  class RoleTypeOthersController < BaseController
    def edit; end

    def update
      form.role_type_other = user_params[:role_type_other]

      if form.save
        if current_user.registration_complete?
          redirect_to user_path, notice: t(:details_updated)
        else
          redirect_to edit_registration_early_years_experience_path
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def user_params
      params.require(:user).permit(:role_type_other)
    end

    # @return [Registration::RoleTypeOtherForm]
    def form
      @form ||= RoleTypeOtherForm.new(user: current_user, role_type_other: current_user.role_type_other)
    end
  end
end
