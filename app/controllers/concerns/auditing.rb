module Auditing
  extend ActiveSupport::Concern

private

  # Authenticates the dedicated accessibility bot for /audit only.
  def authenticate_audit_bot!
    enforce_bot_auth!(scope: 'audit', valid: audit_bot_token?)
  end

  def audit_bot_token?
    token = request.headers['BOT'].to_s
    expected = Rails.configuration.audit_bot_token.to_s

    token.present? && expected.present? &&
      ActiveSupport::SecurityUtils.secure_compare(token, expected)
  end
end
