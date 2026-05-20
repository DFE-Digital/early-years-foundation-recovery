module Registration
  class WhereYouLiveController < BaseController
    def edit; end

    def update
      form.where_you_live = user_params[:where_you_live]

      if form.save
        track('user_where_you_live_change', success: true)
        if current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          redirect_to edit_registration_setting_type_path
        end
      else
        track('user_where_you_live_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:where_you_live)
    end

    # @return [Registration::WhereYouLiveForm]
    def form
      @form ||=
        WhereYouLiveForm.new(
          user: current_user,
          where_you_live: current_user.where_you_live,
        )
    end
  end
end
