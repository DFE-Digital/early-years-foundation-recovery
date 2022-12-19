class Registration::BaseController < ApplicationController
  before_action :authenticate_user!

private

  def complete_journey
    if current_user.registration_complete?
      redirect_to user_path, notice: t('.complete_update')
    else
      complete_registration
    end
  end

  def complete_registration
    track('user_registration', success: true)
    current_user.update! registration_complete: true
    if current_user.display_whats_new?
      current_user.update! display_whats_new: false
      redirect_to whats_new_path, notice: registration_notification
    else
      redirect_to my_modules_path, notice: registration_notification
    end
  end

  def registration_notification
    if current_user.private_beta_registration_complete?
      t('.update_registration')
    else
      t('.complete_registration')
    end
  end

  # @see Auditing
  # @return [Boolean]
  def authenticate_user!
    return true if bot?

    super
  end
end
