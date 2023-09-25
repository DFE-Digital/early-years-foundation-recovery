module Registration
  class EarlyYearsEmailsController < BaseController
    def edit; end

    def update
      form.early_years_emails = user_params[:early_years_emails]

      if form.save
        if current_user.registration_complete?
          redirect_to user_path, notice: t(:details_updated)
        else
          complete_registration
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def user_params
      params.require(:user).permit(:early_years_emails)
    end

    # @return [Registration::EarlyYearsEmailsForm]
    def form
      @form ||= EarlyYearsEmailsForm.new(user: current_user, early_years_emails: current_user.early_years_emails)
    end
  end
end
