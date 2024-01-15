module Registration
  class EarlyYearsExperiencesController < BaseController
    def edit
      track('registration_early_years_experience')
    end

    def update
      form.early_years_experience = user_params[:early_years_experience]

      if form.save
        if current_user.registration_complete?
          redirect_to user_path, notice: t(:details_updated)
        else
          redirect_to edit_registration_training_emails_path
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def user_params
      params.require(:user).permit(:early_years_experience)
    end

    # @return [Registration::RoleTypeForm]
    def form
      @form ||= EarlyYearsExperiencesForm.new(user: current_user, early_years_experience: current_user.early_years_experience)
    end
  end
end
