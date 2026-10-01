# frozen_string_literal: true

module TelemetrySanitizer
  MAX_MESSAGE_BYTES = 8_192
  SENSITIVE_HEADER = %r{
    \b(authorization|proxy-authorization|cookie|set-cookie)
    (\s*(?:=>|=|:)\s*)
    (?:"[^"]*"|'[^']*'|[^\r\n]+)
  }ix
  SENSITIVE_ASSIGNMENT = %r!
    (["']?)
    \b(
      (?:[a-z0-9]+[_-])*
      (?:passw\w*|secret|token|key|crypt|salt|certificate|otp|ssn|email|user(?:_id)?|ip|session)
      (?:[_-][a-z0-9]+)*
    )\b
    \1
    (\s*(?:=>|=|:)\s*)
    (?:"[^"]*"|'[^']*'|[^\s,}]+)
  !ix
  EMAIL_ADDRESS = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  IP_ADDRESS = /\b(?:\d{1,3}\.){3}\d{1,3}\b/
  QUERY_STRING = /\?[^\s"']+/

  def self.sanitize(value)
    value
      .to_s
      .scrub('')
      .gsub(SENSITIVE_HEADER, '\1\2[FILTERED]')
      .gsub(SENSITIVE_ASSIGNMENT, '\1\2\1\3[FILTERED]')
      .gsub(EMAIL_ADDRESS, '[FILTERED]')
      .gsub(IP_ADDRESS, '[FILTERED]')
      .gsub(QUERY_STRING, '?[FILTERED]')
      .byteslice(0, MAX_MESSAGE_BYTES)
      .scrub('')
  end
end
