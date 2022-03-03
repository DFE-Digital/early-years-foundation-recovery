class Questionnaire < YamlBase
  extend YamlFolder
  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming

  set_folder "questionnaires"

  def self.load_file
    raw_data.map do |name, data|
      data['name'] = name
      data['questions'].deep_symbolize_keys!
      data['questions'].keys.each { |question| data[question] = nil }
      data
    end
  end

  def questions
    self[:questions]
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
end
