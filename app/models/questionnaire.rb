class Questionnaire < YamlBase
  extend YamlFolder
  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming

  set_folder 'questionnaires'

  def self.load_file
    data = raw_data.map do |training_module, questionnaires|
      questionnaires.map do |name, data|
        data['name'] = name
        data['training_module'] = training_module
        data['questions'].deep_symbolize_keys!
        data['questions'].each_key { |question| data[question] = nil }
        data
      end
    end
    data.flatten! # Using flatten! as more memory efficient.
    data
  end

  def questions
    self[:questions]
  end

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
end
