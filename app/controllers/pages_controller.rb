# CMS pages
class PagesController < Contentful::BaseController
  helper_method :page

  def show
    if page.present?
      track 'static_page'
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  # @return [::Page]
  def page
    @page ||= ::Page.find_by(name: params[:id]).first
  end
end
