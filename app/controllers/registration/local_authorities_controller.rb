class Registration::LocalAuthoritiesController < Registration::BaseController
  def edit
    @user_form = Users::LocalAuthorityForm.new(user: current_user, setting_type_id: current_user.setting_type_id, local_authority: current_user.local_authority)
  end

  def update
    @user_form = Users::LocalAuthorityForm.new(user_params.merge(user: current_user, setting_type_id: current_user.setting_type_id))

    if @user_form.save
      if @user_form.role_type_next?
        redirect_to edit_registration_role_type_path
      else
        complete_journey
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:local_authority)
  end
end
