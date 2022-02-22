class Topic < YamlBase
  extend YamlFolder

  set_folder "training"

  # Load the about data from training YAML file and use that to create the model instance
  # Use the root key to populate training_module.
  def self.load_file
    nested_hashes = raw_data.map do |training_module, training_data|
      training_data['topics'].map do |name, values|
        values.merge(
          training_module: training_module,
          name: name
        )
      end
    end
    nested_hashes.flatten!
    nested_hashes
  end
end
