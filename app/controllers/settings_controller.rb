class SettingsController < ApplicationController
  def show
    render params[:id].underscore
  end

  def create
    set_analytics_preference
    redirect_to params[:return_url]
  end

private

  def track_analytics
    params.fetch(:track_analytics, 'No')
  end

  def set_analytics_preference
    cookies[:track_analytics] = { value: track_analytics, expires: 6.months.from_now }
    if params.fetch(:notify_if_successful, false)
      flash[:notice] = t('cookie.preferences_saved_html', return_url: helpers.root_path, scope: :settings)
    end
  end
end
