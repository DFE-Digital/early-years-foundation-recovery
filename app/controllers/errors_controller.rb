class ErrorsController < ApplicationController
  def not_found; end

  def timeout
    @user_timeout_minutes = Rails.configuration.user_timeout_minutes
  end

  def internal_server_error; end
end
