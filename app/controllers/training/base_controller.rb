class Training::BaseController < ApplicationController
  # Draft course content can be viewed on the staging deployment or local environment
  before_action do
    ContentfulModel.use_preview_api = Rails.application.preview?
  end
end
