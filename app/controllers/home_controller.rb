class HomeController < ApplicationController
  before_action :authenticate_registered_user!, only: %i[audit]

  def index
    # ensure authors see latest version
    # Training::Module.cache.clear
    Training::Module.reset_cache_key!

    @user = current_user
    track('home_page')
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end

  def audit
    render plain: 'BOT ACCESS GRANTED', status: :ok
  end
end
