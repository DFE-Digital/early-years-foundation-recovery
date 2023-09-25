class UserController < ApplicationController
  before_action :authenticate_registered_user!,
                except: %i[check_email_confirmation check_email_password_reset]

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
      render :edit_name, status: :unprocessable_entity
    end
  end

  # @see config/initializers/devise.rb
  def update_password
    if current_user.update_with_password(user_password_params)
      track('user_password_change', success: true)
      bypass_sign_in(current_user)
      redirect_to user_path, notice: 'Your new password has been saved.'
    else
      track('user_password_change', success: false)
      render :edit_password, status: :unprocessable_entity
    end
  end

  def update_email
    if current_user.update(user_params)
      track('user_email_change', success: true)
      redirect_to user_path, notice: t('notice.email_changed')
    else
      track('user_email_change', success: false)
      render :edit_email, status: :unprocessable_entity
    end
  end

  def update_training_emails
    if current_user.update(user_params)
      track('user_training_emails_change', success: true)
      redirect_to user_path, notice: 'Your email preferences have been saved.'
    else
      track('user_training_emails_change', success: false)
      render :edit_training_emails, status: :unprocessable_entity
    end
  end

  def check_email_confirmation
    return unless params[:ref]

    @user = User.find_by(confirmation_token: params[:ref])
  end

  def check_email_password_reset; end

private

  # def user
  #   @user ||= current_user
  # end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number, :email, :setting_type, :setting_type_other, :training_emails)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
