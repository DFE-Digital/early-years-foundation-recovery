class ModuleItem < YamlBase
  MODELS = {
    module_intro: ContentPage,
    sub_module_intro: ContentPage,
    text_page: ContentPage,
    formative_assessment: Questionnaire
  }

  extend YamlFolder
  set_folder "modules"

  # Override ActiveYaml::Base load_file method to get data nested within file and use parent keys to populate attributes
  def self.load_file
    data = raw_data.map do |training_module, items|
      items.map do |id, values|
        values.merge(id: id.to_s, training_module: training_module)
      end
    end
    data.flatten! # Using flatten! as more memory efficient.
    data
  end

  def model
    klass = MODELS[type.to_sym]
    if klass == Questionnaire
      Questionnaire.find_by(name: id)
    else
      klass.new(attributes)
    end
  end
  delegate :valid?, to: :model

  def next_item
    self.class.all.to_a[place_in_flow + 1]
  end

  def place_in_flow
    self.class.all.to_a.index(self)
  end
  
  def to_param
    id
  end
end
