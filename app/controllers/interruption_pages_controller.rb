class InterruptionPagesController < ApplicationController
  before_action :authenticate_registered_user!
  after_action :track_events, only: :show

  def show
    @training_module_name ||= module_params[:training_module_id]
    @model = InterruptionPage
  end

private

  def module_params
    params.permit(:training_module_id)
  end

  def track_events
    track('interruption_page')
  end
end
