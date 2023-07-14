class Registration::RoleTypesController < Registration::BaseController
  before_action :authenticate_user!

  def edit
    @user_form = Users::RoleTypeForm.new(user: current_user, role_type: current_user.role_type)
  end

  def update
    @user_form = Users::RoleTypeForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if Rails.configuration.feature_email_prefs
        redirect_to edit_registration_training_emails_path
      elsif current_user.registration_complete?
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
    params.require(:user).permit(:role_type)
  end
end
