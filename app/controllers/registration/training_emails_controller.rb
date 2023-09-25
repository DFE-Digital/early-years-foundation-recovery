module Registration
  class TrainingEmailsController < BaseController
    helper_method :back_link

    def edit; end

    def update
      form.training_emails = user_params[:training_emails]

      if form.save
        if current_user.registration_complete?
          redirect_to my_modules_path, notice: t(:details_updated)
        else
          complete_registration
        end
      else
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
      if current_user.role_applicable?
        edit_registration_role_type_path
      elsif current_user.setting_local_authority?
        edit_registration_local_authority_path
      else
        edit_registration_setting_type_path
      end
    end
  end
end
