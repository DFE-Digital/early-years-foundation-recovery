# :nocov:
class ExceptionLoggingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue StandardError => e # StandardError and subclasses
    req    = ActionDispatch::Request.new(env)
    rid    = req.request_id
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    params = filter.filter(req.params).except('controller', 'action')

    cleaned_bt = Rails.backtrace_cleaner.clean(e.backtrace || [])
    cleaned_bt = cleaned_bt.first(20)

    msg = e.message.to_s.gsub(/\s+/, ' ')[0, 500]

    Rails.logger.error do
      [
        "unhandled_exception error_class=#{e.class} message=#{msg.inspect} " \
        "method=#{req.request_method} path=#{req.fullpath.inspect} request_id=#{rid}",
        "params=#{params.inspect}",
        'backtrace:',
        *cleaned_bt.map { |line| "  #{line}" },
      ].join("\n")
    end

    if Rails.respond_to?(:error) && Rails.error.respond_to?(:report)
      Rails.error.report(e, handled: false, context: {
        request_id: rid,
        method: req.request_method,
        path: req.fullpath,
        params: params,
      })
    end

    raise
  end
end
