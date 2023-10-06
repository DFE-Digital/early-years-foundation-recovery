# frozen_string_literal: true

class LearningController < ApplicationController
  before_action :authenticate_registered_user!
  layout 'main_hero'

  # GET /my-modules
  def show
    track('learning_page')
  end
end
