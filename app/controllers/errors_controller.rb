class ErrorsController < ApplicationController
  before_action :log_error

  def not_found
    render status: :not_found
  end

  def unprocessable_content
    render status: :unprocessable_content
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def service_unavailable
    render status: :service_unavailable
  end

private

  def log_error
    track('error_page')
  end
end
