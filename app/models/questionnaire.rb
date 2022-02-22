class Questionnaire < YamlBase
  extend YamlFolder

  set_folder "questionnaires"

  def self.load_file
    raw_data.map do |name, data|
      data['name'] = name
      data['questions'].deep_symbolize_keys!
      data
    end
  end
end
