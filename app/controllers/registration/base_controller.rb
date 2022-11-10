class Registration::BaseController < ApplicationController
  before_action :authenticate_user!

private

  def next_action
    if current_user.registration_complete?
      user_path
    else
      yield
    end
  end

  def complete_registration
    track('user_registration', success: true)
    current_user.update! registration_complete: true
    if current_user.display_whats_new?
      current_user.update! display_whats_new: false
      redirect_to static_path('whats-new'), notice: t('.complete')
    else
      redirect_to my_modules_path, notice: t('.complete')
    end
  end

  # @see Auditing
  # @return [Boolean]
  def authenticate_user!
    return true if bot?

    super
  end
end
