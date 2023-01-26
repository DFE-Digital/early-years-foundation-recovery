class Training::BaseController < ApplicationController
  before_action do
    ContentfulModel.use_preview_api = Rails.application.preview?
  end
end
