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
        flash[:notice] = registration_notification
        redirect_to static_path('whats-new')
      else
        notice_payload = registration_notification
        flash[:notice] = notice_payload
        redirect_to my_modules_path
      end
    end

    def registration_notification
      key = if current_user.private_beta_registration_complete?
              'update_registration'
            else
              'complete_registration'
            end

      notice = I18n.t(key, options: :flash)
      if notice.is_a?(Hash)
        notice.deep_symbolize_keys
      else
        notice
      end
    end

    def complete_registration_banner
      key = 'complete_user_registration'
      notice = I18n.t(key, options: :flash)
      if notice.is_a?(Hash)
        notice.deep_symbolize_keys
      else
        notice
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
