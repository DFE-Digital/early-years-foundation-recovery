class Registration::NamesController < Registration::BaseController
  def edit
    @user_form = Users::NameForm.new(user: current_user, first_name: current_user.first_name, last_name: current_user.last_name)
  end

  def update
    @user_form = Users::NameForm.new(user_params.merge(user: current_user))

    if @user_form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: t('.complete_update')
      else
        redirect_to edit_registration_setting_type_path
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end
end
