class StaticController < Contentful::BaseController
  def show
    if model.present?
      track 'static_page'
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  def model
    @model = Contentful::Static.find_by(name: params[:id]).first
  end
end
