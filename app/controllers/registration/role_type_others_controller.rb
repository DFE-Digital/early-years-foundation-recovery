class Registration::RoleTypeOthersController < Registration::BaseController
  def edit
    @user_form = Users::RoleTypeOtherForm.new(user: current_user, role_type_other: current_user.role_type_other)
  end

  def update
    @user_form = Users::RoleTypeOtherForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: t('.complete_update')
      else
        complete_registration
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:role_type_other)
  end
end
