class UserController < ApplicationController
  before_action :authenticate_registered_user!, except: %i[check_email_confirmation check_email_password_reset]

  def show
    user
  end

  def edit
    user
  end

  def update
    if user.update(user_params)
      redirect_to user_path, notice: 'Profile updated'
    else
      render :edit
    end
  end

  def check_email_confirmation
    @user = User.find(params[:id])
  end

  def check_email_password_reset; end

private

  def user
    @user ||= current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number)
  end
end
