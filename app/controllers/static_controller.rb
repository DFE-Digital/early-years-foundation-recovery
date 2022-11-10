class StaticController < ApplicationController
  def show
    if template_valid?
      track('static_page')
      render template
    else
      render 'errors/not_found'
    end
  end

private

  def template_valid?
    template_exists?(template, lookup_context.prefixes)
  end

  def template
    page_params[:id].underscore
  end

  def page_params
    params.permit(:id)
  end
end
