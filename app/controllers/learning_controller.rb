# frozen_string_literal: true

class LearningController < ApplicationController
  before_action :authenticate_registered_user!

  # GET /my-modules
  def show
    track('learning_page')
  end
end
