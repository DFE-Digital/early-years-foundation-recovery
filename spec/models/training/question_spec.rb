require 'rails_helper'

RSpec.describe Training::Question, type: :model do
  let(:module_id) { 'child-development-and-the-eyfs' }
  describe 'single answer question' do
    subject(:question) do
      described_class.find_by(
        module_id: module_id,
        slug: '1-1-1-1b'
      ).first
    end

    specify { expect(question.id).to eql('1_self_efficacy') }
    specify { expect(question.body).to include('Self-efficacy is a measure of which of the following?') }
    specify { expect(question.component).to eq('formative') }

    specify { expect(question.module_item).to be_a(Training::Page)}
    specify { expect(question.to_param).to eq('1-1-1-1b')}
  
  
    # pagination -------------------------------

    it '#pagination' do
      expect(question.pagination).to eq({current: 3, total: 29})
    end

  end
end
