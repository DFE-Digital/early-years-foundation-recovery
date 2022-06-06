class UserController < ApplicationController
  before_action :authenticate_registered_user!,
                except: %i[check_email_confirmation check_email_password_reset]

  def show
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

  def update_name
    if user.update(user_params)
      ahoy.track('name_changed')
      redirect_to user_path, notice: 'You have saved your details'
    else
      render :edit_name, status: :unprocessable_entity
    end
  end

  # @see config/initializers/devise.rb
  def update_password
    @minimum_password_length = User.password_length.first

    if user.update_with_password(user_password_params)
      ahoy.track('password_changed')
      bypass_sign_in(user)
      redirect_to user_path, notice: 'Your password has been reset'
    else
      render :edit_password, status: :unprocessable_entity
    end
  end

  def update_email
    if user.update(user_params)
      ahoy.track('email_changed')
      redirect_to user_path, notice: 'You have saved your details'
    else
      render :edit_email, status: :unprocessable_entity
    end
  end

  def update_postcode
    if user.update(user_params)
      ahoy.track('postcode_changed')
      redirect_to user_path, notice: 'You have saved your details'
    else
      render :edit_postcode, status: :unprocessable_entity
    end
  end

  def update_ofsted_number
    if user.update(user_params)
      ahoy.track('ofsted_number_changed')
      redirect_to user_path, notice: 'You have saved your details'
    else
      render :edit_ofsted_number, status: :unprocessable_entity
    end
  end

  def check_email_confirmation
    @user = User.find_by(email: params[:email])
  end

  def check_email_password_reset; end

private

  def user
    @user ||= current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :postcode, :ofsted_number, :email)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
