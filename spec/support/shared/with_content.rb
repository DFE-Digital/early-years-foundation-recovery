RSpec.shared_context 'with content' do
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
  #   alpha => {
  #     what-to-expect => {
  #       thpe => interruption_page
  #     }
  #   },
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

  # {
  #   alpha => [
  #     what-to-expect,
  #     before-you-start,
  #     intro,
  #   ],
  #   ...
  # }
  #
  # entries in data/modules/foo.yml
  let(:module_content) do
    module_names.index_with { |mod_name| course_content[mod_name].keys }.to_h
  end

  let(:module_types) do
    module_names.index_with do |mod_name|
      course_content[mod_name].map { |_page, meta| meta['type'] }
    end
  end

  let(:essential_types) do
    %w[
      interruption_page
      icons_page
      module_intro
      sub_module_intro
      text_page
      formative_questionnaire
      video_page
      summary_intro
      recap_page
      assessment_intro
      summative_questionnaire
      assessment_results
      confidence_intro
      confidence_questionnaire
      thankyou
      certificate
    ]
  end

  # {
  #   alpha => [
  #     what-to-expect,
  #     before-you-start,
  #     intro,
  #   ],
  #   ...
  # }
  #
  # entries in config/locales/modules/foo.yml
  let(:page_content) do
    module_names.index_with { |mod_name| I18n.t(mod_name, scope: 'modules').keys.map(&:to_s) }.to_h
  end

  let(:questions) do
    type.classify.constantize.all.group_by { |q| q[:training_module] }
  end

  let(:questions_total) do
    questions.map { |_k, v| v.count }.reduce(&:+)
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
