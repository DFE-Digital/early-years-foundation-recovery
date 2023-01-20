# frozen_string_literal: true

class LearningController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :enable_cms_preview!

  # GET /my-modules
  def show
    track('learning_page')
    @user = current_user
  end
end
