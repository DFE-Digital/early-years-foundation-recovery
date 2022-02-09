class AboutTraining < ActiveYaml::Base
  extend YamlFolder
  
  set_root_path Rails.root.join("data")
  set_filename "training" # Note: this is a folder

  # Load the about data from training YAML file and use that to create the model instance
  # Use the root key to populate training_module.
  def self.load_file
    raw_data.map do |training_module, values|
      values['about'].merge(training_module: training_module)
    end
  end
end
