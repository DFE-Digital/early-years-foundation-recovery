class ErrorsController < ApplicationController
  before_action :log_error

  def not_found
    render status: :not_found
  rescue ActionView::MissingTemplate => e
    # If the template is missing, return a 404 status without rendering any page
    Rails.logger.warn "Missing template: #{e.message}"
    head :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  rescue ActionView::MissingTemplate => e
    # If the template is missing, return a 500 status without rendering any page
    Rails.logger.warn "Missing template: #{e.message}"
    head :internal_server_error
  end

  def service_unavailable
    render status: :service_unavailable
  end

private

  def log_error
    track('error_page')
  end
end
