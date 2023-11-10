module GovOneHelper
  # @return [String]
  def login_uri
    state = SecureRandom.uuid
    session[:gov_one_auth_state] = state unless Rails.env.test?

    params = {
      response_type: 'code',
      scope: 'email openid',
      client_id: Rails.application.config.gov_one_client_id,
      nonce: SecureRandom.uuid,
      state: state,
      redirect_uri: Rails.application.config.gov_one_redirect_uri,
    }

    gov_one_uri('authorize', params)
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: current_id_token,
      state: SecureRandom.uuid,
      post_logout_redirect_uri: Rails.application.config.gov_one_logout_redirect_uri,
    }

    gov_one_uri('logout', params)
  end

private

  # @return [String]
  def current_id_token
    session[:id_token]
  end

  # @param endpoint [String] the gov one endpoint
  # @param params [Hash] query params
  # @return [URI]
  def gov_one_uri(endpoint, params)
    uri = URI.parse("#{Rails.application.config.gov_one_base_uri}/#{endpoint}")
    uri.query = URI.encode_www_form(params)
    uri
  end
end
