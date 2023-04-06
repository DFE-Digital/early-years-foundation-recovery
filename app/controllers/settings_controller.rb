class SettingsController < ApplicationController
  def show
    if template_valid?
      track('static_page')
      render template
    else
      render 'errors/not_found'
    end
  end

  def create
    set_analytics_preference

    if settings_params[:settings_updated].present?
      flash[:notice] = t(:flash, path: root_path, scope: 'settings.cookie')
    end

    redirect_to request_path
  end

private

  def set_analytics_preference
    cookies[:track_analytics] = {
      value: settings_params[:track_analytics],
      expires: 6.months.from_now,
      httponly: true,
    }
  end

  def request_path
    if URI(settings_params[:request_path]).relative?
      settings_params[:request_path]
    else
      settings_path
    end
  end

  def settings_params
    params.permit(:request_path, :track_analytics, :settings_updated)
  end

  def template_valid?
    template_exists?(template, lookup_context.prefixes)
  end

  def template
    page_params[:id].underscore
  end

  def page_params
    params.permit(:id)
  end
end
