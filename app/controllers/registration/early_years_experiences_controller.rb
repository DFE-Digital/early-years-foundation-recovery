module Registration
  class EarlyYearsExperiencesController < BaseController
    def edit; end

    def update
      form.early_years_experience = user_params[:early_years_experience]

      if form.save
        track('user_early_years_experience_change', success: true)
        flash[:important] = complete_registration_banner if returning_user?
        if current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          redirect_to edit_registration_training_emails_path
        end
      else
        track('user_early_years_experience_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:early_years_experience)
    end

    # @return [Registration::EarlyYearsExperiencesForm]
    def form
      @form ||=
        EarlyYearsExperiencesForm.new(
          user: current_user,
          early_years_experience: current_user.early_years_experience,
        )
    end
  end
end
