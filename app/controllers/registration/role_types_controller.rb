module Registration
  class RoleTypesController < BaseController
    def edit; end

    def update
      form.role_type = user_params[:role_type]

      if form.save
        redirect_to edit_registration_early_years_experience_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def user_params
      params.require(:user).permit(:role_type)
    end

    # @return [Registration::RoleTypeForm]
    def form
      @form ||= RoleTypeForm.new(user: current_user, role_type: current_user.role_type)
    end
  end
end
