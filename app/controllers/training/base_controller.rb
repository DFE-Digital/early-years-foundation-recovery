class Training::BaseController < ApplicationController
  before_action { ContentfulModel.use_preview_api = true }
end