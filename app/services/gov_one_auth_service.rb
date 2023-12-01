#
# - exchange an authorisation code for tokens (access and id)
# - exchange an access token for user info
# - decode an id token to get the user's gov one id
#
# @see https://docs.sign-in.service.gov.uk/
class GovOneAuthService
  # @return [Hash{Symbol => String}]
  CALLBACKS = {
    login: "#{Rails.application.config.service_url}/users/auth/openid_connect/callback",
    logout: "#{Rails.application.config.service_url}/users/sign_out",
  }.freeze

  # @return [Hash{Symbol => String}]
  ENDPOINTS = {
    login: "#{Rails.application.config.gov_one_base_uri}/authorize",
    logout: "#{Rails.application.config.gov_one_base_uri}/logout",
    token: "#{Rails.application.config.gov_one_base_uri}/token",
    userinfo: "#{Rails.application.config.gov_one_base_uri}/userinfo",
    jwks: "#{Rails.application.config.gov_one_base_uri}/.well-known/jwks.json",
  }.freeze

  extend Dry::Initializer

  option :code, Types::Strict::String

  # POST /token
  # @return [Hash]
  def tokens
    uri, http = build_http(ENDPOINTS[:token])
    token_request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    token_request.set_form_data(token_body)
    token_response = response(token_request, http)

    JSON.parse(token_response.body)
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.tokens: #{e.message}"
    {}
  end

  # @param token [String]
  # @param nonce [String]
  # @return [Boolean]
  def valid_id_token?(token, nonce)
    token['iss'] == "#{Rails.application.config.gov_one_base_uri}/" &&
      token['aud'] == Rails.application.config.gov_one_client_id &&
      token['nonce'] == nonce
  end

  # GET /userinfo
  # @param access_token [String]
  # @return [Hash]
  def user_info(access_token)
    uri, http = build_http(ENDPOINTS[:userinfo])
    userinfo_request = Net::HTTP::Get.new(uri.path, { 'Authorization' => "Bearer #{access_token}" })
    userinfo_response = response(userinfo_request, http)

    JSON.parse(userinfo_response.body)
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.user_info: #{e.message}"
    {}
  end

  # @param request [Net::HTTP::Get, Net::HTTP::Post]
  # @param http [Net::HTTP]
  # @return [Net::HTTPResponse]
  def response(request, http)
    http.request(request)
  end

  # @param token [String]
  # @return [Array<Hash>]
  def decode_id_token(token)
    kid = JWT.decode(token, nil, false).last['kid']
    key_params = jwks['keys'].find { |key| key['kid'] == kid }
    jwk = JWT::JWK.new(key_params)

    JWT.decode(token, jwk.public_key, true, { verify_iat: true, algorithm: 'ES256' })
  end

  # @param address [String]
  # @return [Array<URI::HTTP, Net::HTTP>]
  def build_http(address)
    uri = URI.parse(address)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    [uri, http]
  end

private

  # GET /.well-known/jwks.json
  # @return [Hash]
  def jwks
    Rails.cache.fetch('jwks', expires_in: 24.hours) do
      uri, http = build_http(ENDPOINTS[:jwks])
      response = http.request(Net::HTTP::Get.new(uri.path))
      JSON.parse(response.body)
    end
  end

  # @return [String]
  def jwt_assertion
    rsa_private = OpenSSL::PKey::RSA.new(Rails.application.config.gov_one_private_key)
    JWT.encode jwt_payload, rsa_private, 'RS256'
  end

  # @return [Hash]
  def jwt_payload
    {
      aud: ENDPOINTS[:token],
      iss: Rails.application.config.gov_one_client_id,
      sub: Rails.application.config.gov_one_client_id,
      exp: Time.zone.now.to_i + 5 * 60,
      jti: SecureRandom.uuid,
      iat: Time.zone.now.to_i,
    }
  end

  # @return [Hash]
  def token_body
    {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: CALLBACKS[:login],
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: jwt_assertion,
    }
  end
end
