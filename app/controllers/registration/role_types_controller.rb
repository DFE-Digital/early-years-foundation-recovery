class Registration::RoleTypesController < Registration::BaseController
  before_action :authenticate_user!

  def edit
    @user_form = Users::RoleTypeForm.new(user: current_user)
  end

  def update
    @user_form = Users::RoleTypeForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: 'Role is updated'
      else
        complete_registration
      end
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:role_type)
  end
end
