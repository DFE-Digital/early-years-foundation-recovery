class ErrorsController < ApplicationController
  before_action :log_error

  def not_found
    render status: 404
  end

  def timeout
    @user_timeout_minutes = Rails.configuration.user_timeout_minutes
  end

  def internal_server_error
    render status: 500
  end

private

  def log_error
    track('error_page')
  end
end
