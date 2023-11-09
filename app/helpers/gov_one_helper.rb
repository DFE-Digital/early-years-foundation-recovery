module GovOneHelper
  # @return [String]
  def login_uri
    state = SecureRandom.uuid
    session[:gov_one_auth_state] = state

    params = {
      response_type: 'code',
      scope: 'email openid',
      client_id: Rails.application.config.gov_one_client_id,
      nonce: SecureRandom.uuid,
      state: state,
    }

    uri = gov_one_uri('authorize', params)
    "#{uri}&redirect_uri=#{Rails.application.config.gov_one_redirect_uri}"
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
      post_logout_redirect_uri: Rails.application.config.gov_one_logout_redirect_uri,
    }

    uri = gov_one_uri('logout', params)
    "#{uri}&post_logout_redirect_uri=#{Rails.application.config.gov_one_logout_redirect_uri}"
  end

private

  # @param endpoint [String] the gov one endpoint
  # @param params [Hash] query params
  def gov_one_uri(endpoint, params)
    uri = URI.parse("#{ENV['GOV_ONE_BASE_URI']}/#{endpoint}")
    uri.query = URI.encode_www_form(params)
    uri
  end
end
