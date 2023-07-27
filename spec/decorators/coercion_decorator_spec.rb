require 'rails_helper'

RSpec.describe CoercionDecorator do
  subject(:decorator) { described_class.new }

  describe '.call' do
    context 'with many records' do
      let(:input) do
        [
          {
            test_percentage: 0.1,
            date: Time.zone.local(2023, 1, 1),
            int: 1,
          },
          {
            test_percentage: 0.2,
            date: Time.zone.local(2023, 1, 2),
            int: 2,
          },
          {
            test_percentage: 0.3,
            date: Time.zone.local(2023, 1, 3),
            int: 3,
          },
        ]
      end

      let(:output) do
        [
          {
            test_percentage: '10.0%',
            date: '2023-01-01 00:00:00',
            int: 1,
          },
          {
            test_percentage: '20.0%',
            date: '2023-01-02 00:00:00',
            int: 2,
          },
          {
            test_percentage: '30.0%',
            date: '2023-01-03 00:00:00',
            int: 3,
          },
        ]
      end

      it do
        result = []
        decorator.call(input) { |row| result << row }
        expect(result).to eq output
      end
    end

    context 'with one record' do
      let(:input) do
        {
          test_percentage: 0.1,
          date: Time.zone.local(2023, 1, 1),
        }
      end

      let(:output) do
        {
          test_percentage: '10.0%',
          date: '2023-01-01 00:00:00',
        }
      end

      it do
        result = []
        decorator.call(input) { |row| result << row }
        expect(result).to eq [output]
      end
    end
  end
end
