class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def openid_connect
    code = params['code']

    auth_service = GovOneAuthService.new(code)
    tokens_response = auth_service.tokens
    access_token = tokens_response['access_token']
    session[:id_token] = tokens_response['id_token']

    user_info_response = auth_service.user_info(access_token)
    @email = user_info_response['email']

    gov_user = find_or_create_user
    sign_in_and_redirect gov_user if gov_user
  end

private

  # @return [User]
  def find_or_create_user
    User.find_by(email: @email) || create_from_email(@email)
  end
end
