class SnippetsController < ApplicationController
  def show
    if Rails.application.preview?
      render html: resource, layout: true
    else
      render 'errors/not_found'
    end
  end

private

  # @return [String] I18n key - dot separated values
  def resource_name
    params.permit(:id)[:id]
  end

  # @return [String]
  def resource
    helpers.content_resource(resource_name)
  end
end
