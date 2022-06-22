class SettingsController < ApplicationController
  def show
    render params[:id].underscore
  end
end
