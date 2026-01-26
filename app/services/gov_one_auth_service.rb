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
  option :http_client, default: -> { Net::HTTP }

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
    keys, _refreshed = fetch_jwks_with_cache
    key_params = keys['keys'].find { |key| key['kid'] == kid }

    unless key_params
      Rails.logger.warn "JWKS kid #{kid} not found in cache, refreshing JWKS..."
      keys, _refreshed = fetch_jwks_with_cache(force_refresh: true)
      key_params = keys['keys'].find { |key| key['kid'] == kid }
      unless key_params
        Rails.logger.error "GovOneAuthService.decode_id_token: kid #{kid} not found after JWKS refresh"
        raise JWT::DecodeError, "kid #{kid} not found in JWKS"
      end
    end

    jwk = JWT::JWK.new(key_params)
    JWT.decode(token, jwk.public_key, true, { verify_iat: true, algorithm: 'ES256' })
  rescue JWT::DecodeError
    # Let JWT::DecodeError propagate
    raise
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.decode_id_token: #{e.message}"
    nil
  end

  # @param address [String]
  # @return [Array<URI::HTTP, Net::HTTP>]
  def build_http(address)
    uri = URI.parse(address)
    http = http_client.new(uri.host, uri.port)
    http.use_ssl = true
    [uri, http]
  rescue StandardError => e
    Rails.logger.error "GovOneAuthService.build_http: #{e.message}"
  end

private

  # Fetch JWKS with cache, supporting force refresh and cache expiry from Cache-Control
  # @param force_refresh [Boolean]
  # @return [Array<Hash, Boolean>] JWKS and whether it was freshly fetched
  def fetch_jwks_with_cache(force_refresh: false)
    cache_key = 'jwks'
    if force_refresh
      Rails.cache.delete(cache_key)
    end
    jwks, expiry = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
      uri, http = build_http(jwks_uri_from_discovery)
      response = http.request(Net::HTTP::Get.new(uri.path))
      if response.code.to_i == 200
        max_age = parse_max_age(response['Cache-Control'])
        Rails.logger.info "Fetched JWKS, setting cache expiry to #{max_age} seconds"
        [JSON.parse(response.body), max_age]
      else
        Rails.logger.error "GovOneAuthService.jwks: HTTP #{response.code}"
        raise 'JWKS fetch failed'
      end
    rescue StandardError => e
      Rails.logger.error "GovOneAuthService.jwks: #{e.message}"
      # fallback: return last cached value if available
      cached = Rails.cache.read(cache_key)
      if cached
        Rails.logger.warn 'Using stale JWKS from cache due to fetch error'
        return [cached[0], false]
      else
        raise
      end
    end
    # Set expiry if max-age present
    if expiry.is_a?(Integer) && expiry.positive?
      Rails.cache.write(cache_key, [jwks, expiry], expires_in: expiry)
    end
    [jwks, true]
  end

  # Parse max-age from Cache-Control header
  def parse_max_age(header)
    return nil unless header

    if (m = header.match(/max-age=(\d+)/))
      m[1].to_i
    end
  end

  # Optionally fetch JWKS URI from OpenID discovery endpoint
  def jwks_uri_from_discovery
    discovery_url = "#{Rails.application.config.gov_one_base_uri}/.well-known/openid-configuration"
    begin
      uri, http = build_http(discovery_url)
      response = http.request(Net::HTTP::Get.new(uri.path))
      if response.code.to_i == 200
        json = JSON.parse(response.body)
        json['jwks_uri'] || ENDPOINTS[:jwks]
      else
        Rails.logger.warn 'OpenID discovery failed, using default JWKS URI'
        ENDPOINTS[:jwks]
      end
    rescue StandardError => e
      Rails.logger.warn "OpenID discovery error: #{e.message}, using default JWKS URI"
      ENDPOINTS[:jwks]
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
