class StaticController < Contentful::BaseController
  def show
    if model.present?
      @cms_title = model
      track 'static_page'
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  def model
    @model = Static.find_by(name: params[:id]).first
  end
end
