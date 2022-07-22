class UserController < ApplicationController
  before_action :authenticate_registered_user!,
                except: %i[check_email_confirmation check_email_password_reset]

  def show
    track('profile_page')
    user
  end

  def edit_name
    user
  end

  def edit_password
    @minimum_password_length = User.password_length.first
    user
  end

  def edit_postcode
    user
  end

  def edit_ofsted_number
    user
  end

  def edit_email
    user
  end

  def edit_setting_type
    user
  end

  def update_name
    if user.update(user_params)
      track('user_name_change', success: true)
      redirect_to user_path, notice: 'You have saved your details'
    else
      track('user_name_change', success: false)
      render :edit_name, status: :unprocessable_entity
    end
  end

  # @see config/initializers/devise.rb
  def update_password
    @minimum_password_length = User.password_length.first

    if user.update_with_password(user_password_params)
      track('user_password_change', success: true)
      bypass_sign_in(user)
      redirect_to user_path, notice: 'Your new password has been saved.'
    else
      track('user_password_change', success: false)
      render :edit_password, status: :unprocessable_entity
    end
  end

  def update_email
    if user.update(user_params)
      track('user_email_change', success: true)
      redirect_to user_path, notice: t('notice.email_changed')
    else
      track('user_email_change', success: false)
      render :edit_email, status: :unprocessable_entity
    end
  end

  def update_postcode
    if user.update(user_params)
      track('user_postcode_change', success: true)
      redirect_to user_path, notice: 'You have saved your details'
    else
      track('user_postcode_change', success: false)
      render :edit_postcode, status: :unprocessable_entity
    end
  end

  def update_ofsted_number
    if user.update(user_params)
      track('ofsted_number_change', success: true)
      redirect_to user_path, notice: 'You have saved your details'
    else
      track('ofsted_number_change', success: false)
      render :edit_ofsted_number, status: :unprocessable_entity
    end
  end

  def update_setting_type
    if user.update(user_params)
      track('user_setting_type_change', success: true)
      redirect_to user_path, notice: 'You have saved your details'
    else
      track('user_setting_type_change', success: false)
      render :edit_postcode, status: :unprocessable_entity
    end
  end

  def check_email_confirmation
    return unless params[:ref]

    @user = User.find_by(confirmation_token: params[:ref])
  end

  def check_email_password_reset; end

private

  def user
    @user ||= current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number, :email, :setting_type, :setting_type_other)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
