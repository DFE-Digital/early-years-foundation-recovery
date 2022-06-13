class HomeController < ApplicationController
  def index
    @user = current_user
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end
end
