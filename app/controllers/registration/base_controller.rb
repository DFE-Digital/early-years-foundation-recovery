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
    redirect_to my_modules_path, notice: t('.complete')
  end

  # @see Auditing
  # @return [Boolean]
  def authenticate_user!
    return true if bot?

    super
  end
end