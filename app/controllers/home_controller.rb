class HomeController < ApplicationController
  before_action :authenticate_registered_user!, only: %i[audit]

  layout 'hero'

  def index
    track('home_page')
    log_caching { render :index }
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end

  def audit
    render plain: 'BOT ACCESS GRANTED', status: :ok
  end
end
