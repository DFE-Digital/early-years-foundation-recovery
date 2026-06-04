module Registration
  class ResearchParticipantsController < BaseController
    def edit; end

    def update
      form.research_participant = user_params[:research_participant]

      if form.save
        track('user_research_participant_change', success: true)
        if current_user.registration_complete?
          redirect_to user_path, notice: helpers.m(:details_updated)
        else
          complete_registration
        end
      else
        track('user_research_participant_change', success: false)
        render :edit, status: :unprocessable_content
      end
    end

  private

    # @return [ActionController::Parameters]
    def user_params
      params.require(:user).permit(:research_participant)
    end

    # @return [Registration::ResearchParticipantForm]
    def form
      @form ||=
        ResearchParticipantForm.new(
          user: current_user,
          research_participant: current_user.research_participant,
        )
    end
  end
end
