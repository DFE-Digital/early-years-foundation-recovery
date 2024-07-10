module Registration
  class NamesController < BaseController
    def edit; end

    def update
      form.first_name = user_params[:first_name]
      form.last_name = user_params[:last_name]

      if form.save
        track('user_name_change', success: true)
        if current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          redirect_to edit_registration_setting_type_path
        end
      else
        track('user_name_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name)
    end

    # @return [Registration::NameForm]
    def form
      @form ||=
        NameForm.new(
          user: current_user,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
        )
    end
  end
end
