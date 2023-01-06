class AccountDeletionsController < ApplicationController
  before_action :authenticate_registered_user!, except: :show

  def show; end

  def new
    current_user
  end

  def update
    if current_user.valid_password?(user_password_params[:current_password])
      redirect_to edit_reason_user_account_deletion_path
    else
      current_user.errors.add(:current_password, :confirmation_invalid, message: 'Enter a valid password')
      render :new, status: :unprocessable_entity
    end
  end

  def reset_password
    sign_out current_user
    redirect_to new_user_password_path
  end

  def delete_account
    current_user.send_account_deleted_notification
    redact_user_info
    sign_out current_user
    redirect_to user_account_deletion_path
  end

  def edit_reason
    current_user
  end

  def update_reason
    current_user.context = :account_deletion

    if current_user.update(user_params)
      redirect_to confirm_delete_account_user_account_deletion_path
    else
      current_user.errors.clear
      if user_params[:deleted_reason] == 'other'
        current_user.errors.add :deleted_reason_other, :blank, message: 'Enter a reason why you want to close your account'
      else
        current_user.errors.add :deleted_reason, :blank, message: 'Select a reason for closing your account'
      end
      render :edit_reason, status: :unprocessable_entity
    end
  end

  def confirm_delete_account; end

private

  def user_params
    params.require(:user).permit(:deleted_reason, :deleted_reason_other)
  end

  def user_password_params
    params.require(:user).permit(:current_password)
  end

  def redact_user_info
    current_user.skip_reconfirmation!
    current_user.update!(first_name: 'Redacted',
                         last_name: 'User',
                         account_deleted_at: Time.zone.now,
                         email: "redacted_user#{current_user.id}@example.com",
                         password: 'redacteduser')
    current_user.notes.update_all(body: nil)
  end
end
