# frozen_string_literal: true

class LearningController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    @user = current_user
    # @end_of_training_module_assessment = TrainingModule.find_by(name: ENV['SUMMATIVE_ASSESSMENT_NAME'])
  end
end
