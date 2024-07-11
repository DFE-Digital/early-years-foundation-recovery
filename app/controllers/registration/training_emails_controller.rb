module Registration
  class TrainingEmailsController < BaseController
    def edit; end

    def update
      form.training_emails = user_params[:training_emails]

      if form.save
        track('user_training_emails_change', success: true)
        if current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          complete_registration
        end
      else
        track('user_training_emails_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:training_emails)
    end

    # @return [Registration::TrainingEmailsForm]
    def form
      @form ||=
        TrainingEmailsForm.new(
          user: current_user,
          training_emails: current_user.training_emails,
        )
    end
  end
end
