# Controller handling OmniAuth callbacks for user authentication.
# This controller uses the GovOneAuthService to retrieve user informaton and create or sign in an user based on the email address or gov one id

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # This method is called by Devise after successful Gov One Login authentication
  # @return [nil]
  def openid_connect
    return unless session_params? && valid_params?

    auth_service = GovOneAuthService.new(code: params['code'])
    tokens_response = auth_service.tokens
    return error_redirect unless valid_tokens?(tokens_response)

    id_token = auth_service.decode_id_token(tokens_response['id_token'])[0]
    session[:id_token] = tokens_response['id_token']
    gov_one_id = id_token['sub']
    return error_redirect unless auth_service.valid_id_token?(id_token, session[:gov_one_auth_nonce])

    user_info_response = auth_service.user_info(tokens_response['access_token'])
    email = user_info_response['email']
    return error_redirect unless valid_user_info?(user_info_response)

    gov_user = User.find_or_create_from_gov_one(email: email, gov_one_id: gov_one_id)

    delete_session_params
    sign_in_and_redirect gov_user if gov_user
  end

private

  # @return [Boolean]
  def valid_params?
    params['code'].present? && params['state'].present? && params['state'] == session[:gov_one_auth_state]
  end

  # check state and nonce are saved in session
  # @return [Boolean]
  def session_params?
    session[:gov_one_auth_state].present? && session[:gov_one_auth_nonce].present?
  end

  # @param tokens_response [Hash]
  # @return [Boolean]
  def valid_tokens?(tokens_response)
    tokens_response.present? && tokens_response['access_token'].present? && tokens_response['id_token'].present?
  end

  # @param user_info_response [Hash]
  # @return [Boolean]
  def valid_user_info?(user_info_response)
    user_info_response.present? && user_info_response['email'].present? && user_info_response['sub'] == session[:id_token]['sub']
  end

  # @return [nil]
  def error_redirect
    flash[:alert] = 'There was a problem signing in. Please try again.'
    redirect_to root_path
  end

  # @return [nil]
  def delete_session_params
    session.delete(:gov_one_auth_state)
    session.delete(:gov_one_auth_nonce)
  end

  # @return [String]
  def after_sign_in_path_for(resource)
    if resource.registration_complete?
      if resource.display_whats_new?
        resource.display_whats_new = false
        resource.save!
        static_path('whats-new')
      elsif !resource.email_preferences_complete?
        static_path('email-preferences')
      else
        my_modules_path
      end
    elsif resource.private_beta_registration_complete?
      static_path('new-registration')
    else
      edit_registration_name_path
    end
  end
end
