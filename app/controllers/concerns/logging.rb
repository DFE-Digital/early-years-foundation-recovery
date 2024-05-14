# Rescue errors and create Sentry alerts
#
module Logging
  extend ActiveSupport::Concern

private

  def log_caching
    begin
      yield
    rescue HTTP::TimeoutError
      Sentry.capture_message "Repopulating cache #{ENV['DOMAIN']}", level: :info
      yield
    end
  end
end
