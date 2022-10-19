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

  # @see Auditing
  # @return [Boolean]
  def authenticate_user!
    return true if bot?

    super
  end
end