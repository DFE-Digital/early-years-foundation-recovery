# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'hero'

  def new
    render 'gov_one'
  end

  # @return [nil]
  def sign_in_test_user
    unless Rails.application.live?
      test_user = User.test_user
      sign_in_and_redirect test_user if test_user
    end
  end

protected

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
      edit_registration_terms_and_conditions_path
    end
  end
end
