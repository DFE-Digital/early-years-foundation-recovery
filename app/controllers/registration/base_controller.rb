#
# Registration journey order:
#
#   1. terms_and_conditions (one-off)
#   2. name
#   3. where_you_live
#   4. setting_type / setting_type_other
#   5. local_authority
#   6. role_type / role_type_other
#   7. early_years_experience
#   8. training_emails
#   9. research_participant
#  10. check_your_answers
#
module Registration
  class BaseController < ApplicationController
    REVIEW_FLAG = :registration_review

    before_action :authenticate_user!
    before_action :enable_review_mode
    helper_method :form, :reviewing?

  private

    # When the user arrives from "Check your answers" we
    # remember it so that every subsequent step returns them there.
    def enable_review_mode
      session[REVIEW_FLAG] = true if params[:return_to] == 'check_your_answers'
    end

    # @return [Boolean] user is editing answers from the Check your answers page
    def reviewing?
      !current_user.registration_complete? && session[REVIEW_FLAG].present?
    end

    def end_review_mode!
      session.delete(REVIEW_FLAG)
    end

    # Send the user to the first outstanding field, otherwise
    # return them to the Check your answers page.
    #
    # @return [String]
    def resume_registration_path
      next_incomplete_step_path || edit_registration_check_your_answers_path
    end

    # @return [String, nil] next registration field still needing an answer
    def next_incomplete_step_path
      user = current_user

      return edit_registration_name_path if user.first_name.blank? || user.last_name.blank?
      return edit_registration_where_you_live_path if user.country.blank?
      return edit_registration_setting_type_path if user.setting_type_id.blank?
      return edit_registration_setting_type_other_path if user.setting_other? && user.setting_type_other.blank?
      return edit_registration_local_authority_path if local_authority_outstanding?
      return edit_registration_role_type_path if role_outstanding?
      return edit_registration_role_type_other_path if user.role_other? && user.role_type_other.blank?
      return edit_registration_early_years_experience_path if experience_outstanding?
      return edit_registration_training_emails_path if user.training_emails.nil?

      nil
    end

    # @return [Boolean]
    def england?
      current_user.country.to_s.casecmp('England').zero?
    end

    # @return [Boolean]
    def local_authority_outstanding?
      england? && !!current_user.setting&.local_authority? && current_user.local_authority.blank?
    end

    # @return [Boolean]
    def role_outstanding?
      !!current_user.setting&.has_role? && current_user.role_type.blank?
    end

    # @return [Boolean]
    def experience_outstanding?
      role = current_user.role_type
      role.present? && role != I18n.t(:na) && current_user.early_years_experience.blank?
    end

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
  end
end
