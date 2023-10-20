module GovOneHelper
  # @return [String]
  def login_uri
    "#{ENV['GOV_ONE_AUTH_URI']}&nonce=#{SecureRandom.uuid}&state=#{SecureRandom.uuid}"
  end

  # @return [String]
  def logout_uri
    "#{ENV['GOV_ONE_SIGN_OUT_URI']}?id_token_hint=#{session[:id_token]}&post_logout_redirect_uri=#{ENV['GOV_ONE_SIGN_OUT_REDIRECT_URI']}&state=#{SecureRandom.uuid}"
  end
end
