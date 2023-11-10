module GovOneHelper
  # @return [String]
  def login_uri
    params = {
      response_type: 'code',
      scope: 'email openid',
      client_id: Rails.application.config.gov_one_client_id,
      nonce: SecureRandom.uuid,
      state: SecureRandom.uuid,
      redirect_uri: Rails.application.config.gov_one_redirect_uri,
    }

    session[:gov_one_auth_state] = params[:state]

    gov_one_uri('authorize', params).to_s
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
      post_logout_redirect_uri: Rails.application.config.gov_one_logout_redirect_uri,
    }

    gov_one_uri('logout', params).to_s
  end

private

  # @param endpoint [String]
  # @param params [Hash]
  # @return [URI::HTTP, URI::HTTPS]
  def gov_one_uri(endpoint, params)
    uri = URI.parse("#{ENV['GOV_ONE_BASE_URI']}/#{endpoint}")
    uri.query = URI.encode_www_form(params)
    uri
  end
end
