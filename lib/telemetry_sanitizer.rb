# frozen_string_literal: true

module TelemetrySanitizer
  MAX_MESSAGE_BYTES = 8_192
  SENSITIVE_ASSIGNMENT = %r!
    (["']?)
    \b(
      (?:[a-z0-9]+[_-])*
      (?:passw\w*|secret|token|key|crypt|salt|certificate|otp|ssn|email|user(?:_id)?|ip)
      (?:[_-][a-z0-9]+)*
    )\b
    \1
    (\s*(?:=|:)\s*)
    (?:"[^"]*"|'[^']*'|[^\s,}]+)
  !ix
  EMAIL_ADDRESS = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  IP_ADDRESS = /\b(?:\d{1,3}\.){3}\d{1,3}\b/
  USER_REFERENCE = /\b(for\s+user|user(?:_id)?)\s+\d+\b/i
  QUERY_STRING = /\?[^\s]+/

  def self.sanitize(value, max_bytes: MAX_MESSAGE_BYTES)
    value
      .to_s
      .scrub('')
      .gsub(SENSITIVE_ASSIGNMENT, '\1\2\1\3[FILTERED]')
      .gsub(EMAIL_ADDRESS, '[FILTERED]')
      .gsub(IP_ADDRESS, '[FILTERED]')
      .gsub(USER_REFERENCE, '\1 [FILTERED]')
      .gsub(QUERY_STRING, '?[FILTERED]')
      .byteslice(0, max_bytes)
      .scrub('')
  end
end
