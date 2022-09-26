# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
protected

  def after_sign_in_path_for(resource)
    if resource.registration_complete?
      if resource.display_whats_new
        resource.display_whats_new = false
        resource.save!
        static_path('whats-new')
      else
        my_learning_path
      end
    else
      extra_registrations_path
    end
  end
end
