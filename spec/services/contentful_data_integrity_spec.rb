require 'rails_helper'

RSpec.describe ContentfulDataIntegrity do
  subject(:service) do
    described_class.new(module_name: mod)
  end

  context 'when module is not found' do
    let(:mod) { 'foo' }

    it 'raises constraint error' do
      expect { service }.to raise_error Dry::Types::ConstraintError
    end
  end

  context 'when module is not specified' do
    let(:mod) { nil }

    it 'raises constraint error' do
      expect { service }.to raise_error Dry::Types::ConstraintError
    end
  end

  describe '#valid?' do
    context 'when valid' do
      let(:mod) { 'alpha' }

      specify { expect(service.valid?).to eq true }
    end

    context 'when invalid' do
      let(:mod) { 'delta' }

      specify { expect(service.valid?).to eq false }
    end
  end

  describe '#consecutive_integers_from_one?' do
    let(:mod) { 'charlie' }
    let(:output) { service.consecutive_integers_from_one?(input) }

    context 'when not consecutive' do
      let(:input) { [1, 2, 3, 4, 6] }

      specify { expect(output).to be false }
    end

    context 'when 1 is not first' do
      let(:input) { [2, 3, 4, 5] }

      specify { expect(output).to be false }
    end

    context 'when valid' do
      let(:input) { [1, 2, 3, 4, 5] }

      specify { expect(output).to be true }
    end
  end

  # This is not part of the service - these are true spec only assertions
  #
  describe 'test modules' do
    context 'alpha' do
      let(:mod) { 'alpha' }

      specify { expect(service.mod.formative_questions.count).to eq 3 }
      specify { expect(service.mod.summative_questions.count).to eq 4 }
      specify { expect(service.mod.confidence_questions.count).to eq 3 }
    end

    context 'bravo' do
      let(:mod) { 'bravo' }

      specify { expect(service.mod.formative_questions.count).to eq 1 }
      specify { expect(service.mod.summative_questions.count).to eq 2 }
      specify { expect(service.mod.confidence_questions.count).to eq 3 }
    end

    context 'charlie' do
      let(:mod) { 'charlie' }

      specify { expect(service.mod.formative_questions.count).to eq 1 }
      specify { expect(service.mod.summative_questions.count).to eq 2 }
      specify { expect(service.mod.confidence_questions.count).to eq 3 }
    end
  end
end
