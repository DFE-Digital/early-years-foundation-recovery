class TrainingModule < YamlBase
  set_filename 'training-modules'

  def self.load_file
    # Override basic behaviour so that root key is stored as name
    raw_data.map do |name, values|
      values.merge(name: name)
    end
  end

  def about_training
    @about_training ||= AboutTraining.find_by(training_module: name)
  end

  def topics
    @topics ||= Topic.where(training_module: name)
  end

  def recap_training
    @recap_training ||= RecapTraining.find_by(training_module: name)
  end
end
