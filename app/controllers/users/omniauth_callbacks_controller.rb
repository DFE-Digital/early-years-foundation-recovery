class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def openid_connect
    code = params['code']

    auth_service = GovOneAuthService.new(code)
    tokens_response = auth_service.tokens
    if tokens_response.empty? || tokens_response['access_token'].blank? || tokens_response['id_token'].blank?
      flash[:alert] = 'There was a problem signing in. Please try again.'
      redirect_to root_path and return
    end

    access_token = tokens_response['access_token']

    user_info_response = auth_service.user_info(access_token)
    if user_info_response.empty? || user_info_response['email'].blank?
      flash[:alert] = 'There was a problem signing in. Please try again.'
      redirect_to root_path and return
    end
    gov_user = find_or_create_user(user_info_response['email'], tokens_response['id_token'])
    sign_in_and_redirect gov_user if gov_user
  end

private

  # @return [User]
  def find_or_create_user(email, id_token)
    existing_user = User.find_by(email: email)

    if existing_user
      existing_user.update!(id_token: id_token)
    else
      existing_user = User.find_by(id_token: id_token) || User.create_from_gov_one(email: email, id_token: id_token)
    end
    existing_user
  end

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
