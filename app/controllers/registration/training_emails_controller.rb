class Registration::TrainingEmailsController < Registration::BaseController
  def edit
    @user_form = Users::TrainingEmailsForm.new(user: current_user, training_emails: current_user.training_emails)
    if current_user.role_type_applicable?
      @back_link_href = edit_registration_role_type_path
    elsif current_user.local_authority_setting?
      @back_link_href = edit_registration_local_authority_path
    else
      @back_link_href = edit_registration_setting_type_path
    end
  end

  def update
    @user_form = Users::TrainingEmailsForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to my_modules_path, notice: t('.complete_update')
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
end
