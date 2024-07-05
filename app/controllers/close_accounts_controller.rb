class CloseAccountsController < ApplicationController
  before_action :authenticate_registered_user!, except: :show

  def show; end

  def update
    redirect_to edit_reason_user_close_account_path
  end

  def reset_password
    sign_out current_user
    redirect_to new_user_password_path
  end

  # TODO: use deliver_later for closed accounts
  def close_account
    NotifyMailer.account_closed(current_user).deliver_now
    NotifyMailer.account_closed_internal(current_user).deliver_now
    current_user.redact!
    sign_out current_user
    redirect_to user_close_account_path
  end

  def edit_reason; end

  def update_reason
    current_user.context = :close_account

    if user_params[:closed_reason] == 'other' && user_params[:closed_reason_custom].blank?
      params[:user][:closed_reason_custom] = 'No reason provided'
    end

    if current_user.update(user_params)
      redirect_to confirm_user_close_account_path
    else
      current_user.errors.clear
      current_user.errors.add :closed_reason, :blank, message: 'Select a reason for closing your account'
      render :edit_reason, status: :unprocessable_entity
    end
  end

  def confirm; end

private

  def user_params
    params.require(:user).permit(:closed_reason, :closed_reason_custom)
  end
end
