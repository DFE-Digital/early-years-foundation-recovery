# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
protected

  def after_sign_in_path_for(resource)
    if resource.registration_complete?
      my_learning_path
    else
      extra_registrations_path
    end
  end
end
