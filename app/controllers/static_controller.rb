# YAML pages
class StaticController < ApplicationController
  before_action :authenticate_registered_user!, if: :restricted?

  def show
    if template_valid?
      track('static_page')
      render "pages/#{template}"
    else
      render 'errors/not_found', status: :not_found
    end
  end

private

  # @return [Boolean]
  def restricted?
    %w[whats-new email-preferences].include? page_params[:id]
  end

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
