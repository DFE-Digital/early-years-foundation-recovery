# YAML pages
class StaticController < ApplicationController
  def show
    if template_valid?
      track('static_page')
      render "pages/#{template}"
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  def template_valid?
    template_exists?(template, :pages)
  end

  def template
    page_params[:id].underscore
  end

  def page_params
    params.permit(:id)
  end
end
