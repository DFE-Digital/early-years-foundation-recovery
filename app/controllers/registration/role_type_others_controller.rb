class Registration::RoleTypeOthersController < Registration::BaseController
  def edit
    @user_form = Users::RoleTypeOtherForm.new(user: current_user)
  end

  def update
    @user_form = Users::RoleTypeOtherForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: 'Role is updated'
      else
        track('user_registration', success: true)
        current_user.update! registration_complete: true
        redirect_to my_modules_path, notice: t('.complete', scope: :registration)
      end
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:role_type_other)
  end
end
