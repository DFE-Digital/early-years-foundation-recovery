module Registration
  class WhereYouLiveController < BaseController
    def edit; end

    def update
      form.where_you_live = user_params[:where_you_live]

      if form.save
        track('user_where_you_live_change', success: true)
        redirect_to edit_registration_setting_type_path
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
          where_you_live: selected_where_you_live,
        )
    end

    # @return [String]
    def selected_where_you_live
      value = current_user.country.to_s.strip
      location = Trainee::Location.all.find do |candidate|
        candidate.id == value || candidate.name.casecmp(value).zero?
      end

      location&.id || value
    end
  end
end
