# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'hero' if Rails.application.gov_one_login?

  def new
    render 'gov_one' if Rails.application.gov_one_login?
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
    elsif Rails.application.gov_one_login?
      edit_registration_terms_and_conditions_path
    else
      edit_registration_name_path
    end
  end
end
