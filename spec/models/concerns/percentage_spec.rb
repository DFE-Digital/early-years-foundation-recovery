require 'rails_helper'

RSpec.describe Percentage do
  let(:percentage) { Class.new { include Percentage } }

  describe '.calculate_percentage' do
    context 'when numerator is 0' do
      it 'returns 0' do
        expect(percentage.calculate_percentage(0, 10)).to eq(0)
      end
    end

    context 'when denominator is 0' do
      it 'returns 0' do
        expect(percentage.calculate_percentage(10, 0)).to eq(0)
      end
    end

    context 'when numerator and denominator are not 0' do
      it 'returns the percentage' do
        expect(percentage.calculate_percentage(10, 100)).to eq(10)
      end
    end
  end

  describe '.format_percentages' do
    context 'when data is an array of arrays' do
      it 'returns the data with float values formatted as percentages' do
        data = [[1.0, 2.0], [3.0, 4.0]]
        expect(percentage.format_percentages(data)).to eq([['1.0%', '2.0%'], ['3.0%', '4.0%']])
      end
    end

    context 'when data is an array of floats' do
      it 'returns the data with float values formatted as percentages' do
        data = [1.0, 2.0]
        expect(percentage.format_percentages(data)).to eq(['1.0%', '2.0%'])
      end
    end
  end
end
