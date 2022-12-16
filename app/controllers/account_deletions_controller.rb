class AccountDeletionsController < ApplicationController
  before_action :authenticate_registered_user!

  def edit
    user
  end

  def edit_reason
    user
  end

  def update
    if user.valid_password?(user_password_params[:current_password])
      redirect_to edit_reason_user_account_deletion_path
    else
      user.errors.add(:current_password, :confirmation_invalid, message: 'Enter a valid password')
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_account
    user.send_account_deleted_notification
    redact_user_info
    sign_out user
    redirect_to static_path('account-deleted')
  end

  def update_reason
    user.context = :account_deletion

    if user.update(user_params)
      redirect_to confirm_delete_account_user_account_deletion_path
    else
      user.errors.clear
      if user_params[:deleted_reason] == 'other'
        user.errors.add :deleted_reason_other, :blank, message: 'Enter a reason why you want to close your account'
      else
        user.errors.add :deleted_reason, :blank, message: 'Select a reason for closing your account'
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

  def user
    @user ||= current_user
  end

  def redact_user_info
    user.skip_reconfirmation!
    user.update!(first_name: 'Redacted', last_name: 'User', account_deleted_at: Time.zone.now,
                 email: "redacted_user#{user.id}@example.com", password: 'redacteduser')
    user.notes.update_all(body: nil)
  end
end
