class StaticController < Contentful::BaseController
  helper_method :model

  def show
    if model.present?
      @cms_static = model
      track 'static_page'
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  def model
    Static.find_by(name: params[:id]).first
  end
end
