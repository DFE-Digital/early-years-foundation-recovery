class TrainingController < ApplicationController
  def index
    @about_training = training_module.about_training
  end

  def show
    @training =  Training.find_by(training_module: training_module.name, name: params[:id])
    @next_training = next_training
  end

  def recap
    @recap_training = training_module.recap_training
  end

  private

  def training_module
    @training_module ||= TrainingModule.find_by(name: params[:training_module_id])
  end

  def next_training
    index = training_module.trainings.to_ary.index(@training)
    training = training_module.trainings.to_ary[index + 1]
    return recap_training_module_training_index_path(training_module) unless training

    [training_module, training]
  end
end
