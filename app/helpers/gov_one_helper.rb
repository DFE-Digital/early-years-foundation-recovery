module GovOneHelper
  # @return [String]
  def login_uri
    params = {
      response_type: 'code',
      scope: 'email openid',
      client_id: Rails.application.config.gov_one_client_id,
      nonce: SecureRandom.uuid,
      state: SecureRandom.uuid,
      redirect_uri: GovOneAuthService::CALLBACKS[:login],
    }

    session[:gov_one_auth_state] = params[:state]

    gov_one_uri(:login, params)
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
      post_logout_redirect_uri: GovOneAuthService::CALLBACKS[:logout],
    }

    gov_one_uri(:logout, params)
  end

private

<<<<<<< HEAD
  # @return [String]
  def current_id_token
    session[:id_token]
  end

  # @param endpoint [String] the gov one endpoint
  # @param params [Hash] query params
  # @return [URI]
=======
  # @param endpoint [Symbol]
  # @param params [Hash]
  # @return [URI::HTTP, URI::HTTPS]
>>>>>>> gov-one-refactor
  def gov_one_uri(endpoint, params)
    uri = URI.parse(GovOneAuthService::ENDPOINTS[endpoint])
    uri.query = URI.encode_www_form(params)
    uri
  end
end
