
# :nocov:
# frozen_string_literal: true

# Middleware to remove the 'Server' header from all HTTP responses
class RemoveServerHeader
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    headers.delete('Server')
    [status, headers, response]
  end
end
# :nocov:
