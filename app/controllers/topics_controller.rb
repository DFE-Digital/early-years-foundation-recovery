class TopicsController < ApplicationController
  def index
    @about_training = training_module.about_training
  end

  def show
    @topic =  Topic.find_by(training_module: training_module.name, name: params[:id])
    @next_topic = next_topic(@topic)
  end

  def recap
    @recap_training = training_module.recap_training
  end

  private

  def training_module
    @training_module ||= TrainingModule.find_by(name: params[:training_module_id])
  end

  def next_topic(topic)
    index = training_module.topics.to_ary.index(topic)
    next_topic = training_module.topics.to_ary[index + 1]
    return recap_training_module_topics_path(training_module) unless next_topic

    [training_module, next_topic]
  end
end
