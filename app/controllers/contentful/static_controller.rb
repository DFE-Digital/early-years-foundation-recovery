class Contentful::StaticController < Contentful::BaseController
  def show
    @model = Contentful::Static.find_by(name: params[:id]).first

    if @model.present?
      track('static_page')
    else
      render 'errors/not_found'
    end
  end
end
