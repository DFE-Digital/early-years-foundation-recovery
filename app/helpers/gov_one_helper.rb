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

    gov_one_uri(:login, params).to_s
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
      post_logout_redirect_uri: GovOneAuthService::CALLBACKS[:logout],
    }

    gov_one_uri(:logout, params).to_s
  end

  # @return [String]
  def login_button
    govuk_button_link_to t('gov_one.links.sign_in'), login_uri
  end

  # @return [String]
  def logout_button
    govuk_button_link_to t('gov_one.links.sign_out'), logout_uri
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
