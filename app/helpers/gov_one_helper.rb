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

    uri = URI.parse("#{Rails.application.config.gov_one_base_uri}/authorize")
    uri.query = URI.encode_www_form(params)
    "#{uri.to_s}&redirect_uri=#{ENV['GOV_ONE_REDIRECT_URI']}"
  end

  # @return [String]
  def logout_uri
    params = {
      id_token_hint: session[:id_token],
      state: SecureRandom.uuid,
    }

    uri = URI.parse("#{Rails.application.config.gov_one_base_uri}/logout")
    uri.query = URI.encode_www_form(params)
    "#{uri.to_s}&post_logout_redirect_uri=#{ENV['GOV_ONE_LOGOUT_REDIRECT_URI']}"
  end
end
