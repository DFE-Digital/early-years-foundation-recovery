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

    uri = uri_constructor('authorize', params)
    "#{uri}&redirect_uri=#{ENV['GOV_ONE_REDIRECT_URI']}"
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
    }

    uri = uri_constructor('logout', params)
    "#{uri}&post_logout_redirect_uri=#{ENV['GOV_ONE_LOGOUT_REDIRECT_URI']}"
  end

private

  def uri_constructor(endpoint, params)
    uri = URI.parse("#{ENV['GOV_ONE_BASE_URI']}/#{endpoint}")
    uri.query = URI.encode_www_form(params)
    uri
  end
end
