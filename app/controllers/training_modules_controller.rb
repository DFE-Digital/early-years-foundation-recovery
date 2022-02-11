class TrainingModulesController < ApplicationController
  before_action :authenticate_registered_user!

  def index
    @training_modules = TrainingModule.all
  end
end
