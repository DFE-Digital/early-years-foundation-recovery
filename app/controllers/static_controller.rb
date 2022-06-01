class StaticController < ApplicationController
  def show
    render params[:id].underscore
  end
end
