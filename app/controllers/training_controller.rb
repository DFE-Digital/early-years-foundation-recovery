# frozen_string_literal: true

class TrainingController < ApplicationController
  before_action :authenticate_registered_user!

  # "My learning" tab
  def index
    @user = current_user
    @started = current_user.modules_by_state(:started)
    @not_started = current_user.modules_by_state(:not_started)
    @completed = current_user.modules_by_state(:completed)

    render 'user/learning'
  end
end
