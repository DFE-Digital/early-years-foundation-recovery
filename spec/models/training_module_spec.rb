require 'rails_helper'

RSpec.describe TrainingModule, type: :model do
  let(:training_module) { described_class.first }

  describe '.load_file' do
    let(:training_module_data) { data_from_file('demo-modules.yml') }

    it 'loads models from expected path' do
      expect(training_module.title).to eq(training_module_data.values.first['title'])
    end

    it 'uses root key to store name' do
      expect(training_module.name).to eq(training_module_data.keys.first)
    end
  end

  it 'has fields' do
    expect(training_module.attributes.keys).to eq(%i[title thumbnail description objective criteria duration summative_threshold name id])
  end

  # predicates ---------------------------------

  # describe '#draft?' do
  # end

  # collections -------------------------

  # describe '#questionnaires' do
  # end

  # describe '#module_items' do
  # end

  # describe '#module_items_by_type' do
  # end

  # describe '#module_items_by_submodule' do
  # end

  # describe '#items_by_submodule' do
  # end

  # describe '#items_by_topic' do
  # end

  # sequence ---------------------------------

  describe '#interruption_page' do
    it 'is the first page' do
      expect(training_module.interruption_page.id).to be 1
      expect(training_module.interruption_page.name).to eql 'before-you-start'
    end
  end

  describe '#expectation_page' do
    it 'is the second page' do
      expect(training_module.expectation_page.id).to be 2
      expect(training_module.expectation_page.name).to eql 'what-to-expect'
    end
  end

  describe '#intro_page' do
    it 'is the third page' do
      expect(training_module.intro_page.id).to be 3
      expect(training_module.intro_page.name).to eql 'intro'
    end
  end

  # describe '#first_submodule_intro_page' do
  # end

  describe '#first_content_page' do
    it 'is the fifth page' do
      expect(training_module.first_content_page.id).to be 5
      expect(training_module.first_content_page.name).to eql '1-1-1'
    end
  end
end
