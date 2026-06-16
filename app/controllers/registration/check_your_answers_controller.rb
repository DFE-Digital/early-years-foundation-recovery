module Registration
  class CheckYourAnswersController < BaseController
    # Arriving back on the summary ends any in-progress review of answers.
    def edit
      end_review_mode!
    end

    def update
      track('user_check_your_answers', success: true)

      if current_user.registration_complete?
        redirect_to user_path, notice: helpers.m(:details_updated)
      else
        complete_registration
      end
    end
  end
end
