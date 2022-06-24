# frozen_string_literal: true

class LearningController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    @user = current_user
  end
end
