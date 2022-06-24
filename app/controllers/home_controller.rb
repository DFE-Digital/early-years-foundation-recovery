class HomeController < ApplicationController
  def index
    @user = current_user
    track('home_page')
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end
end
