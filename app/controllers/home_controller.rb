class HomeController < ApplicationController
  before_action :authenticate_registered_user!, only: %i[audit]

  layout 'hero'

  def index
    track('home_page')

    flash.now[:important] = t('banners.gov_one') unless Rails.application.gov_one_login?
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end

  def audit
    render plain: 'BOT ACCESS GRANTED', status: :ok
  end
end
