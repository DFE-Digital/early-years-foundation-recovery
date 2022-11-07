class AccountDeletionsController < ApplicationController
  before_action :authenticate_registered_user!

  def edit
    user
  end

  def update
    if user.valid_password?(user_password_params[:current_password])
      redirect_to confirm_delete_account_user_account_deletion_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_account
    user.send_account_deleted_notification
    redact_user_info
    sign_out user
    redirect_to static_path('account-deleted')
  end

  def confirm_delete_account; end

private

  def user_password_params
    params.require(:user).permit(:current_password)
  end

  def user
    @user ||= current_user
  end

  def redact_user_info
    user.skip_reconfirmation!
    user.update!(first_name: 'Redacted', last_name: 'User', account_deleted_at: Time.zone.now, 
      email: "redacted_user#{user.id}@example.com", password: "redacteduser", ofsted_number: nil)
    user.notes.update_all(body: nil)
  end
end