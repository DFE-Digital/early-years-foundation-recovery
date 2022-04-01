class YamlBase < ActiveYaml::Base
  set_root_path Rails.root.join('data')

  def to_param
    name
  end
end
