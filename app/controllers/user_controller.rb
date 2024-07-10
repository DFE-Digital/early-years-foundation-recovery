class UserController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    track('profile_page')
  end

  def edit_name; end

  def edit_password; end

  def edit_email; end

  def edit_training_emails; end

  def update_name
    if current_user.update(user_params)
      track('user_name_change', success: true)
      redirect_to user_path, notice: 'You have saved your details'
    else
      track('user_name_change', success: false)
      render :edit_name, status: :unprocessable_content
    end
  end

  def update_training_emails
    if current_user.update(user_params)
      track('user_training_emails_change', success: true)
      redirect_to user_path, notice: 'Your email preferences have been saved.'
    else
      track('user_training_emails_change', success: false)
      render :edit_training_emails, status: :unprocessable_content
    end
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number, :email, :setting_type, :setting_type_other, :training_emails)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
