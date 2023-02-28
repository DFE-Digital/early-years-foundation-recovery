require 'rails_helper'

RSpec.describe ContentfulDataIntegrity do
  subject(:data_integrity) { described_class.new(environment: 'test', training_module: mod, cached: true) }

  let(:mod) { 'alpha' }

  context 'when module does not exist' do
    let(:mod) { 'foo' }

    it 'returns error message' do
      expect { data_integrity.valid? }.to raise_error 'Module does not exist'
    end
  end

  context 'when module does exist and is valid' do
    let(:mod) { 'alpha' }

    it 'returns true' do
      expect(data_integrity.valid?).to eq true
    end
  end

  describe 'when given an array of consecutive numbers' do
    context 'and is not consecutive' do
      let(:nums) { [1, 2, 3, 4, 6] }

      specify do
        expect(data_integrity.consecutive_nums_start_at_one?(nums)).to eq false
      end
    end

    context 'and is consecutive but does not start at 1' do
      let(:nums) { [2, 3, 4, 5] }

      specify do
        expect(data_integrity.consecutive_nums_start_at_one?(nums)).to eq false
      end
    end

    context 'and is consecutive and starts at 1' do
      let(:nums) { [1, 2, 3, 4, 5] }

      specify do
        expect(data_integrity.consecutive_nums_start_at_one?(nums)).to eq true
      end
    end
  end

  describe 'test modules' do
    let(:formative) { data_integrity.find_module_by_name.formative_questions }
    let(:summative) { data_integrity.find_module_by_name.summative_questions }
    let(:confidence) { data_integrity.find_module_by_name.confidence_questions }

    describe 'alpha' do
      let(:mod) { 'alpha' }

      specify { expect(formative.count).to eq 3 }
      specify { expect(summative.count).to eq 4 }
      specify { expect(confidence.count).to eq 3 }
    end

    describe 'bravo' do
      let(:mod) { 'bravo' }

      specify { expect(formative.count).to eq 1 }
      specify { expect(summative.count).to eq 2 }
      specify { expect(confidence.count).to eq 3 }
    end

    describe 'charlie' do
      let(:mod) { 'charlie' }

      specify { expect(formative.count).to eq 1 }
      specify { expect(summative.count).to eq 2 }
      specify { expect(confidence.count).to eq 3 }
    end
  end
end
