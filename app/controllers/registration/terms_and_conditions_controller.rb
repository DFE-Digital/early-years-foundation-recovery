module Registration
  class TermsAndConditionsController < BaseController
    def edit; end

    def update
      form.terms_and_conditions_agreed_at = user_params[:terms_and_conditions_agreed_at]

      if form.save
        track('user_terms_and_conditions_agreed_at_change', success: true)
        flash[:important] = complete_registration_banner
        if current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          redirect_to edit_registration_name_path
        end
      else
        track('user_terms_and_conditions_agreed_at_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:terms_and_conditions_agreed_at)
    end

    # @return [Registration::TermsAndConditionsForm]
    def form
      @form ||=
        TermsAndConditionsForm.new(
          user: current_user,
          terms_and_conditions_agreed_at: current_user.terms_and_conditions_agreed_at,
        )
    end
  end
end
