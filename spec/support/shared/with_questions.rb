RSpec.shared_context 'with questions' do
  # /srv/data/modules/alpha.yml
  # /srv/data/modules/bravo.yml
  # /srv/data/modules/charlie.yml
  #
  # /srv/data/modules/brain-development-and-how-children-learn.yml
  # /srv/data/modules/child-development-and-the-eyfs.yml
  # /srv/data/modules/personal-social-and-emotional-development.yml
  #
  let(:module_data) do
    Rails.root.join('data/modules').children.select { |mod| mod.extname.eql?('.yml') }
  end

  # {
  #   alpha => { before-you-start...
  #   bravo => { before-you-start...
  #   ...
  # }
  #
  let(:course_content) do
    module_data.map { |source| YAML.load_file(source) }.map(&:reduce).to_h
  end

  # alpha
  # bravo
  # charlie
  #
  # brain-development-and-how-children-learn
  # child-development-and-the-eyfs
  # personal-social-and-emotional-development
  #
  let(:module_names) do
    module_data.map { |mod| File.basename(mod, '.yml') }
  end

  let(:data_dir) { 'data/formative-questionnaires' }

  let(:type) { 'formative_questionnaire' }

  let(:questionnaire_data) do
    Rails.root.join(data_dir).children.select { |mod| mod.extname.eql?('.yml') }
  end

  let(:questionnaire_content) do
    questionnaire_data.map { |source| YAML.load_file(source) }.map(&:reduce).to_h
  end

  it 'question pages have question data' do
    module_names.map do |mod_name|
      questions = questionnaire_content[mod_name]
      question_pages = course_content[mod_name].select { |_name, meta| meta['type'].eql?(type) }

      expect(questions.present?).to eql question_pages.present?

      if question_pages && questions
        expect(questions.keys - question_pages.keys).to be_empty
      end
    end
  end
end
