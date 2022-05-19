class SettingsController < ApplicationController
  def show
    render template: "settings/#{params[:id]}"
  end
end
