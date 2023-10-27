class GovOneAuthService
  # @param code [String]
  def initialize(code)
    @code = code
  end

  # @return [Hash]
  def tokens
    body = {
      grant_type: 'authorization_code',
      code: @code,
      redirect_uri: ENV['GOV_ONE_REDIRECT_URI'],
      client_assertion_type: ENV['GOV_ONE_CLIENT_ASSERTION_TYPE'],
      client_assertion: ENV['GOV_ONE_CLIENT_ASSERTION'] || jwt_assertion,
    }

    token_uri = URI.parse("#{ENV['GOV_ONE_BASE_URI']}/token")
    http = build_http(token_uri)

    token_request = Net::HTTP::Post.new(token_uri.path, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    token_request.set_form_data(body)
    token_response = http.request(token_request)

    JSON.parse(token_response.body)
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.tokens: #{e.message}"
    {}
  end

  # @param access_token [String]
  # @return [Hash]
  def user_info(access_token)
    userinfo_uri = URI.parse("#{ENV['GOV_ONE_BASE_URI']}/userinfo")
    http = build_http(userinfo_uri)

    userinfo_request = Net::HTTP::Get.new(userinfo_uri.path, { 'Authorization' => "Bearer #{access_token}" })
    userinfo_response = http.request(userinfo_request)

    JSON.parse(userinfo_response.body)
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.user_info: #{e.message}"
    {}
  end

private

  # @param uri [URI]
  # @return [Net::HTTP]
  def build_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http
  end

  # @return [String]
  def jwt_assertion
    rsa_private = OpenSSL::PKey::RSA.new(Rails.application.config.gov_one_private_key)

    payload = {
      aud: "#{ENV['GOV_ONE_BASE_URI']}/token",
      iss: ENV['GOV_ONE_CLIENT_ID'],
      sub: ENV['GOV_ONE_CLIENT_ID'],
      exp: Time.zone.now.to_i + 5 * 60,
      jti: SecureRandom.uuid,
      iat: Time.zone.now.to_i,
    }

    JWT.encode payload, rsa_private, 'RS256'
  end
end
