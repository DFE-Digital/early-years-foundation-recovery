module Registration
  class TermsAndConditionsController < BaseController
    def edit; end

    def update
      form.terms_and_conditions_agreed_at = user_params[:terms_and_conditions_agreed_at]

      if form.save
        if current_user.registration_complete?
          redirect_to user_path, notice: t(:details_updated)
        else
          redirect_to edit_registration_name_path
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    # @return [Hash]
    def user_params
      params.require(:user).permit(:terms_and_conditions_agreed_at)
    end

    # @return [Registration::NameForm]
    def form
      @form ||=
        TermsAndConditionsForm.new(
          user: current_user,
          terms_and_conditions_agreed_at: current_user.terms_and_conditions_agreed_at,
        )
    end
  end
end
