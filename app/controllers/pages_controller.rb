class PagesController < ApplicationController
  before_action :authenticate_registered_user!, if: :restricted?
  helper_method :page

  def show
    if page.present?
      track 'static_page'
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  # TODO: potential for CMS entry to control this
  # @return [Boolean]
  def restricted?
    %w[whats-new email-preferences].include? page_params[:id]
  end

  # @return [::Page]
  def page
    ::Page.by_name(page_params[:id])
  end

  def page_params
    params.permit(:id)
  end
end
