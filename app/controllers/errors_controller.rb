class ErrorsController < ApplicationController
  def not_found; end

  def timeout
    @user_timeout_minutes = Rails.configuration.x.user_timeout_minutes
  end
end
