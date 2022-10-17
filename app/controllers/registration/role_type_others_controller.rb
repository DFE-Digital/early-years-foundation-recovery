class Registration::RoleTypeOthersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user_form = Users::RoleTypeOtherForm.new(user: current_user)
  end

  def update
    @user_form = Users::RoleTypeOtherForm.new(user_params.merge(user: current_user))

    if @user_form.save
      track('user_registration', success: true)
      current_user.update! registration_complete: true
      redirect_to my_modules_path, notice: t(:complete, scope: :extra_registration)
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:role_type_other)
  end
end