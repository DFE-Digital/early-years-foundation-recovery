class ErrorsController < ApplicationController
  def not_found
    if request.path =~ /\.(png|jpg|jpeg|gif|css|js|pdf)$/
      # If the missing file is a static asset, return a 404 status without rendering the 404 page
      head :not_found
    else
      # For other requests, render the 404 page as usual
      render status: :not_found
    end
  rescue ActionView::MissingTemplate => e
    # If the template is missing, log the warning and return a 404 status
    Rails.logger.warn "Missing template: #{e.message}"
    head :not_found
  end

  def internal_server_error
    if request.path =~ /\.(png|jpg|jpeg|gif|css|js|pdf)$/
      # If the request is for a static asset, return a 500 status without rendering the 500 page
      head :internal_server_error
    else
      # For other requests, render the 500 page as usual
      render status: :internal_server_error
    end
  rescue ActionView::MissingTemplate => e
    # If the template is missing, log the warning and return a 500 status
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
