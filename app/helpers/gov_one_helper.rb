module GovOneHelper
  # @return [String]
  def login_uri
    state = SecureRandom.uuid
    nonce = SecureRandom.uuid
    session[:gov_one_auth_state] = state
    "#{ENV['GOV_ONE_AUTH_URI']}&nonce=#{nonce}&state=#{state}"
  end

  # @return [String]
  def logout_uri
    "#{ENV['GOV_ONE_SIGN_OUT_URI']}?id_token_hint=#{session[:id_token]}&post_logout_redirect_uri=#{ENV['GOV_ONE_SIGN_OUT_REDIRECT_URI']}&state=#{SecureRandom.uuid}"
  end
end
