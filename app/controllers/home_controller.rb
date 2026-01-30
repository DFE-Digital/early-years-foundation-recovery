class HomeController < ApplicationController
  before_action :authenticate_registered_user!, only: %i[audit]

  layout 'hero'

  def index
    track('home_page')
    @public_modules = Training::Module.ordered.reject(&:draft?)
    @public_modules.each do |mod|
      custom_desc = I18n.t("training_module_custom_descriptions.#{mod.name}.description", default: '')

      # override the description method for this instance
      mod.define_singleton_method(:description) { custom_desc }
    end
    log_caching { render :index }
  end

  def show
    render json: { status: 'HEALTHY' }, status: :ok
  end

  def audit
    render plain: 'BOT ACCESS GRANTED', status: :ok
  end
end
