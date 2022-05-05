class TrainingModule < YamlBase
  set_filename 'training-modules'

  def self.load_file
    # Override basic behaviour so that root key is stored as name
    raw_data.map do |name, values|
      values.merge(name: name)
    end
  end
end
