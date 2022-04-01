class StaticController < ApplicationController
  def show
    render params[:id]
  end
end
