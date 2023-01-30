class CloseAccountsController < ApplicationController
  before_action :authenticate_registered_user!, except: :show

  def show; end

  def new
    current_user
  end

  def update
    if current_user.valid_password?(user_password_params[:current_password])
      redirect_to edit_reason_user_close_account_path
    else
      current_user.errors.add(:current_password, :confirmation_invalid, message: 'Enter a valid password')
      render :new, status: :unprocessable_entity
    end
  end

  def reset_password
    sign_out current_user
    redirect_to new_user_password_path
  end

  def close_account
    current_user.send_account_closed_notification
    User.new(email: @internal_mailbox).send_account_closed_internal_notification(current_user.email)
    current_user.redact!
    sign_out current_user
    redirect_to user_close_account_path
  end

  def edit_reason
    current_user
  end

  def update_reason
    current_user.context = :close_account

    if current_user.update(user_params)
      redirect_to confirm_user_close_account_path
    else
      current_user.errors.clear
      if user_params[:closed_reason] == 'other'
        current_user.errors.add :closed_reason_custom, :blank, message: 'Enter a reason why you want to close your account'
      else
        current_user.errors.add :closed_reason, :blank, message: 'Select a reason for closing your account'
      end
      render :edit_reason, status: :unprocessable_entity
    end
  end

  def confirm; end

private

  def user_params
    params.require(:user).permit(:closed_reason, :closed_reason_custom)
  end

  def user_password_params
    params.require(:user).permit(:current_password)
  end
end
