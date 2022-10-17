class ErrorsController < ApplicationController
  before_action :log_error

  def timeout
    @user_timeout_minutes = Rails.configuration.user_timeout_minutes
  end

  # 404 error
  def not_found
    render status: :not_found
  end

  # 422 error
  def unprocessable_entity
    render status: :unprocessable_entity
  end

  # 500 error
  def internal_server_error
    render status: :internal_server_error
  end

private

  def log_error
    track('error_page')
  end
end
