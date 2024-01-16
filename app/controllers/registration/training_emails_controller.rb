module Registration
  class TrainingEmailsController < BaseController
    helper_method :back_link

    def edit; end

    def update
      form.training_emails = user_params[:training_emails]

      if form.save
        track('user_training_emails_change', { success: true })
        if current_user.registration_complete?
          redirect_to my_modules_path, notice: t(:details_updated)
        else
          complete_registration
        end
      else
        track('user_training_emails_change', { success: false })
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def user_params
      params.require(:user).permit(:training_emails)
    end

    # @return [Registration::TrainingEmailsForm]
    def form
      @form ||= TrainingEmailsForm.new(user: current_user, training_emails: current_user.training_emails)
    end

    # @return [String]
    def back_link
      referer_from_email_preferences? ? '/email-preferences' : edit_registration_early_years_experience_path
    end

    def referer_from_email_preferences?
      request.referer&.include?('/email-preferences')
    end
  end
end
