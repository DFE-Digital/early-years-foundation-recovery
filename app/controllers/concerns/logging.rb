# Rescue errors and create Sentry alerts
#
module Logging
  extend ActiveSupport::Concern

private

  # @yield [nil]
  def log_caching
    yield
  rescue HTTP::TimeoutError, Contentful::Error
    message = "Repopulating cache #{ENV['ENVIRONMENT']} #{self.class.name}"
    Sentry.capture_message message, level: :info
    yield
  end
end
