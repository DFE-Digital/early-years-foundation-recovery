module GovOneHelper
  # @return [URI]
  def login_uri
    params = {
      redirect_uri: GovOneAuthService::CALLBACKS[:login],
      client_id: Rails.application.config.gov_one_client_id,
      response_type: 'code',
      scope: 'email openid',
      nonce: SecureRandom.uuid,
      state: SecureRandom.uuid,
    }

    session[:gov_one_auth_state] = params[:state]

    gov_one_uri(:login, params)
  end

  # @return [URI]
  def logout_uri
    params = {
      post_logout_redirect_uri: GovOneAuthService::CALLBACKS[:logout],
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
    }

    gov_one_uri(:logout, params)
  end

  # @return [String]
  def login_button
    govuk_button_link_to t('gov_one_info.sign_in_button'), login_uri.to_s
  end

private

  # @param endpoint [Symbol]
  # @param params [Hash]
  # @return [URI::HTTP, URI::HTTPS]
  def gov_one_uri(endpoint, params)
    uri = URI.parse(GovOneAuthService::ENDPOINTS[endpoint])
    uri.query = URI.encode_www_form(params)
    uri
  end
end
