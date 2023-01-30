class Contentful::StaticController < Contentful::BaseController
  def show
    if template_valid?
      track('static_page')
      @model = find_page(template)

      render static_page
    else
      render 'errors/not_found'
    end
  end

private

  def static_page
    find_page(template_titleize)
  end

  def template_valid?
    !find_page(template).nil?
  end

  def template_titleize
    params[:id].titleize
  end

  def template
    params[:id]
  end

  def find_page(params)
    Contentful::Static.find_by(name: params).first
  end
end
