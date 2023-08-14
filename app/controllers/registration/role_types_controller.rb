class Registration::RoleTypesController < Registration::BaseController
  def edit; end

  def update
    form.role_type = user_params[:role_type]

    if form.save
      if current_user.registration_complete?
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
    params.require(:user).permit(:role_type)
  end

  # @return [Users::RoleTypeForm]
  def form
    @form ||= Users::RoleTypeForm.new(user: current_user, role_type: current_user.role_type)
  end
end
