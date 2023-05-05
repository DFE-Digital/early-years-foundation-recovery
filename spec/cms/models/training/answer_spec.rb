require 'rails_helper'

RSpec.describe Training::Answer, :cms, type: :model do
  # Q. Is the Earth flat?
  subject(:answer) do
    described_class.new(json: json)
  end

  let(:json) do
    [%w[True], ['False', true]]
  end

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  describe '#options' do
    it 'can be disabled' do
      expect(answer.options.first).not_to be_disabled
      expect(answer.options(disabled: true).first).to be_disabled
    end

    it 'can be checked' do
      expect(answer.options.first).not_to be_checked
      expect(answer.options(checked: [1]).first).to be_checked
      expect(answer.options(checked: [1]).last).not_to be_checked
    end
  end

  describe '#valid?' do
    context 'when valid (radio)' do
      specify { expect(answer).to be_valid }
    end

    context 'when valid (checkbox)' do
      # Q. Planets in our solar system?
      let(:json) do
        [
          %w[Kepler-22B],
          ['Venus', true],
          ['Mars', true],
        ]
      end

      specify { expect(answer).to be_valid }
    end

    context 'when empty' do
      let(:json) do
        []
      end

      specify { expect(answer).not_to be_valid }
    end

    context 'when only one option exists' do
      let(:json) do
        [%w[True]]
      end

      specify { expect(answer).not_to be_valid }
    end

    context 'when no option is correct' do
      let(:json) do
        [%w[True], %w[False]]
      end

      specify { expect(answer).not_to be_valid }
    end

    context 'when a label is blank' do
      let(:json) do
        [%w[True], ['', true]]
      end

      specify { expect(answer).not_to be_valid }
    end
  end
end
