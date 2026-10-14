# frozen_string_literal: true

module TelemetrySanitizer
  MAX_MESSAGE_BYTES = 8_192
  SENSITIVE_HEADER = %r{
    (["']?)\b(authorization|proxy-authorization|cookie|set-cookie)\1
    (\s*(?:=>|=|:)\s*)
    (?:"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[^\r\n]+)
  }ix
  SENSITIVE_ASSIGNMENT = %r~
    (?<![a-z0-9_-])
    (?<quote>["']?)
    (?<key>[a-z0-9_-]+)
    \k<quote>
    (?<separator>\s*(?:=>|=|:)\s*)
    (?<value>"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[^\s,}]+)
  ~ix
  SENSITIVE_KEY_COMPONENT = /\A(?:passw\w*|secret|token|key|crypt\w*|salt|certificate|otp|ssn|email|user(?:_id)?|ip|session)\z/i
  EMAIL_ADDRESS = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  IP_ADDRESS = /\b(?:\d{1,3}\.){3}\d{1,3}\b/
  QUERY_STRING = /\?[^\s"']+/

  def self.sanitize(value)
    value
      .to_s
      .scrub('')
      .gsub(SENSITIVE_HEADER, '\1\2\1\3[FILTERED]')
      .gsub(SENSITIVE_ASSIGNMENT) { |assignment| redact_sensitive_assignment(assignment, Regexp.last_match) }
      .gsub(EMAIL_ADDRESS, '[FILTERED]')
      .gsub(IP_ADDRESS, '[FILTERED]')
      .gsub(QUERY_STRING, '?[FILTERED]')
      .byteslice(0, MAX_MESSAGE_BYTES)
      .scrub('')
  end

  def self.redact_sensitive_assignment(assignment, match)
    normalized_key = match[:key]
                      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                      .gsub(/([a-z0-9])([A-Z])/, '\1_\2')
    return assignment unless normalized_key.split(/[_-]/).any? { |part| SENSITIVE_KEY_COMPONENT.match?(part) }

    "#{match[:quote]}#{match[:key]}#{match[:quote]}#{match[:separator]}[FILTERED]"
  end
  private_class_method :redact_sensitive_assignment
end
