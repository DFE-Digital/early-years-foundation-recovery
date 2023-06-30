require 'rails_helper'

RSpec.describe CoercionDecorator do
  describe '.call' do

    context 'when input is an array of hashes' do
      let(:input) do
        [{
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
         }]
      end

      let(:formatted_input) do
        [{
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
         }]
      end

      let(:output) { described_class.new(input).call }

      it 'formats the dates and percentages' do
        expect(output).to eq(formatted_input)
      end
    end

    context 'when input is not an array of hashes' do
      it 'raises a ConstraintError' do
        expect { described_class.new('some string').call }.to raise_error(Dry::Types::ConstraintError)
      end
    end
  end
end
