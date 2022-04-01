# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
protected

  def after_sign_in_path_for(resource)
    super if resource.registration_complete?

    extra_registrations_path
  end
end
