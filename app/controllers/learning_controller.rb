# frozen_string_literal: true

class LearningController < ApplicationController
  before_action :authenticate_registered_user!
  layout 'hero'

  # GET /my-modules
  def show
    track('learning_page')
  end
end
