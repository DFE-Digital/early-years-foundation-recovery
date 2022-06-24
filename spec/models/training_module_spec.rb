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
    expect(described_class.field_names).to eq %i[
      title thumbnail description objective criteria duration name depends_on draft
    ]
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

  # describe '#interruption_page' do
  # end

  # describe '#intro_page' do
  # end

  # describe '#first_content_page' do
  # end
end
