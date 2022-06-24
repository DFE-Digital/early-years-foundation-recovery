class StaticController < ApplicationController
  def show
    track('static_page')
    render params[:id].underscore
  end
end
