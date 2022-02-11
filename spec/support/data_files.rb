def data_from_file(path)
  YAML.load_file(Rails.root.join("data", path))
end
