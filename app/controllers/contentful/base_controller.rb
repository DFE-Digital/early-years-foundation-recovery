class Contentful::BaseController < ApplicationController
  include ContentfulRails::Preview
  # extend ContentfulRails::Preview

  def check_preview_domain
    binding.pry
  end
end
