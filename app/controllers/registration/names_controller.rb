class Registration::NamesController < Registration::BaseController
  def edit; end

  def update
    form.first_name = user_params[:first_name]
    form.last_name = user_params[:last_name]

    if form.save
      if current_user.registration_complete?
        redirect_to user_path, notice: t(:details_updated)
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

  # @return [Users::NameForm]
  def form
    @form ||=
      Users::NameForm.new(
        user: current_user,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
      )
  end
end
