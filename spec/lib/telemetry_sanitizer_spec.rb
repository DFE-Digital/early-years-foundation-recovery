# frozen_string_literal: true

require_relative '../../lib/telemetry_sanitizer'

RSpec.describe TelemetrySanitizer do
  it 'redacts compound credentials, email addresses, IP addresses, and query strings' do
    message = 'api_key=abc access_token: xyz client_secret=>123 user@example.com 192.0.2.1 /path?code=secret'

    expect(described_class.sanitize(message)).to eq(
      'api_key=[FILTERED] access_token: [FILTERED] client_secret=>[FILTERED] ' \
      '[FILTERED] [FILTERED] /path?[FILTERED]',
    )
  end

  it 'redacts authentication and cookie headers' do
    message = "Authorization: Bearer secret\nCookie: session=abc\nSet-Cookie=remember_token=xyz"

    expect(described_class.sanitize(message)).to eq(
      "Authorization: [FILTERED]\nCookie: [FILTERED]\nSet-Cookie=[FILTERED]",
    )
  end

  it 'redacts before truncating and preserves valid UTF-8' do
    message = "#{'a' * 8_180} email=user@example.com €"
    sanitized = described_class.sanitize(message)

    expect(sanitized.bytesize).to be <= described_class::MAX_MESSAGE_BYTES
    expect(sanitized).not_to include('user@example.com')
    expect(sanitized).to be_valid_encoding
  end
end
