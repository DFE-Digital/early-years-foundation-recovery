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
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: jwt_assertion,
    }

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
    http = build_http(userinfo_uri)

    userinfo_request = Net::HTTP::Get.new(userinfo_uri.path, { 'Authorization' => "Bearer #{access_token}" })
    userinfo_response = http.request(userinfo_request)

    JSON.parse(userinfo_response.body)
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.user_info: #{e.message}"
    {}
  end

  # @param token [String]
  # @return [Array<Hash>]
  def decode_id_token(token)
    kid = JWT.decode(token, nil, false).last['kid']
    key_params = jwks['keys'].find { |key| key['kid'] == kid }
    jwk = JWT::JWK.new(key_params)

    JWT.decode(token, jwk.public_key, true, algorithm: 'ES256')
  end

private

  # @return [URI]
  def token_uri
    URI.parse("#{ENV['GOV_ONE_BASE_URI']}/token")
  end

  def userinfo_uri
    URI.parse("#{ENV['GOV_ONE_BASE_URI']}/userinfo")
  end

  # @param uri [URI]
  # @return [Net::HTTP]
  def build_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true unless Rails.env.test?
    http
  end

  def jwks
    discovery_url = "#{ENV['GOV_ONE_BASE_URI']}/.well-known/jwks.json"
    uri = URI.parse(discovery_url)
    http = build_http(uri)
    response = http.request(Net::HTTP::Get.new(uri.path))
    JSON.parse(response.body)
  end

  # @return [String]
  def jwt_assertion
    rsa_private = OpenSSL::PKey::RSA.new(Rails.application.config.gov_one_private_key)

    payload = {
      aud: "#{ENV['GOV_ONE_BASE_URI']}/token",
      iss: Rails.application.config.gov_one_client_id,
      sub: Rails.application.config.gov_one_client_id,
      exp: Time.zone.now.to_i + 5 * 60,
      jti: SecureRandom.uuid,
      iat: Time.zone.now.to_i,
    }

    JWT.encode payload, rsa_private, 'RS256'
  end
end
