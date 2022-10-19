class Registration::SettingTypesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user_form = Users::SettingForm.new(user: current_user)
  end

  def update
    @user_form = Users::SettingForm.new(user_params.merge(user: current_user))

    if @user_form.save
      redirect_to edit_registration_local_authority_path
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:setting_type)
  end
end
