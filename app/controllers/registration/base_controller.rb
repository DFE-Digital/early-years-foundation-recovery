#
# Registration journey order:
#
#   1. terms_and_conditions (one-off)
#   2. name
#   3. setting_type / setting_type_other
#   4. local_authority
#   5. role_type / role_type_other
#   6. early_years_experience
#   7. training_emails
#
module Registration
  class BaseController < ApplicationController
    before_action :authenticate_user!
    helper_method :form

  private

    def complete_registration
      track('user_registration', success: true)
      current_user.update! registration_complete: true

      if current_user.display_whats_new?
        current_user.update! display_whats_new: false
        redirect_to static_path('whats-new'), notice: registration_notification
      else
        redirect_to my_modules_path, notice: registration_notification
      end
    end

    # @return [String]
    def registration_notification
      if current_user.private_beta_registration_complete?
        t(:update_registration)
      else
        t(:complete_registration)
      end
    end

    # @see Auditing
    # @return [Boolean]
    def authenticate_user!
      return true if bot?

      super
    end
  end
end
