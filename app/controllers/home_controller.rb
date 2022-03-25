class HomeController < ApplicationController
  def index
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end
end
