# frozen_string_literal: true

class TrainingController < ApplicationController
  before_action :authenticate_registered_user!

  # "My learning" tab
  def index
    @user = current_user
    @started = current_user.learning(state: :started)
    @not_started = current_user.learning(state: :not_started)
    render 'user/learning'
  end
end
