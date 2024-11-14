# @see GovOneAuthService
#
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # This method is called by Devise after successful Gov One Login authentication
  # @return [nil]
  def openid_connect
    if params['error'].present?
      Rails.logger.error("Authentication error: #{params['error']}, #{params['error_description']}")
      return error_redirect('Params errors present')
    end

    return error_redirect('Session_params & Valid_params error') unless session_params? && valid_params?

    auth_service = GovOneAuthService.new(code: params['code'])
    tokens_response = auth_service.tokens
    return error_redirect('No valid_tokens') unless valid_tokens?(tokens_response)

    id_token = auth_service.decode_id_token(tokens_response['id_token'])[0]
    return error_redirect('No valid_id_token') unless valid_id_token?(id_token)

    session[:id_token] = tokens_response['id_token']
    gov_one_id = id_token['sub']

    user_info_response = auth_service.user_info(tokens_response['access_token'])
    email = user_info_response['email']
    return error_redirect('No valid_user_info') unless valid_user_info?(user_info_response, gov_one_id)

    gov_user = User.find_or_create_from_gov_one(email: email, gov_one_id: gov_one_id)

    delete_session_params
    Rails.logger.info("Logging in: #{gov_user}")
    sign_in_and_redirect gov_user if gov_user
  end

private

  # @return [Boolean]
  def valid_params?
    params['code'].present? && params['state'].present? && params['state'] == session[:gov_one_auth_state]
  end

  # @return [Boolean]
  def session_params?
    session[:gov_one_auth_state].present? && session[:gov_one_auth_nonce].present?
  end

  # @param tokens_response [Hash]
  # @return [Boolean]
  def valid_tokens?(tokens_response)
    tokens_response.present? &&
      tokens_response['access_token'].present? &&
      tokens_response['id_token'].present? &&
      tokens_response['error'].blank?
  end

  # @param id_token [Hash]
  # @return [Boolean]
  def valid_id_token?(id_token)
    id_token.present? &&
      id_token['nonce'] == session[:gov_one_auth_nonce] &&
      id_token['iss'] == "#{Rails.application.config.gov_one_base_uri}/" &&
      id_token['aud'] == Rails.application.config.gov_one_client_id
  end

  # @param user_info_response [Hash]
  # @return [Boolean]
  def valid_user_info?(user_info_response, gov_one_id)
    user_info_response.present? &&
      user_info_response['email'].present? &&
      user_info_response['sub'] == gov_one_id &&
      user_info_response['error'].blank?
  end

  # @return [nil]
  def error_redirect(msg = 'default message')
    return if user_signed_in?

    flash[:alert] = 'There was a problem signing in. Please try again.'
    redirect_to root_path
  rescue StandardError => e
    Rails.logger.error("Error redirect: #{e.message} - #{msg}")
  end

  # @return [nil]
  def delete_session_params
    session.delete(:gov_one_auth_state)
    session.delete(:gov_one_auth_nonce)
  end

  # 1. /my-modules                                (default)
  # 2. /whats-new                                 (static interruption page)
  # 2. /email-preferences                         (static interruption page)
  # 3. /registration/terms-and-conditions/edit    (new account)
  #
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
    else
      edit_registration_terms_and_conditions_path
    end
  end
end
