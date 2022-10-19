class Registration::LocalAuthoritiesController < Registration::BaseController
  def edit
    @user_form = Users::LocalAuthorityForm.new(user: current_user)
  end

  def update
    @user_form = Users::LocalAuthorityForm.new(user_params.merge(user: current_user))

    if @user_form.save
      redirect_to next_action { edit_registration_role_type_path }
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:local_authority)
  end
end
