require Rails.root.join('app/middleware/exception_logging_middleware')

Rails.application.config.middleware.insert_before(
  ActionDispatch::ShowExceptions,
  ExceptionLoggingMiddleware,
)
