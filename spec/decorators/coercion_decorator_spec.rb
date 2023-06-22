require 'rails_helper'

RSpec.describe CoercionDecorator do
  describe '.call' do
    subject(:decorator) { described_class.new }

    let(:input) do
      {
        test_percentage: 0.5,
        date: Time.zone.local(2023, 1, 1),
        array: [1, 2, 3],
      }
    end

    let(:formatted_output) do
      {
        test_percentage: '50.0%',
        date: '2023-01-01 00:00:00',
        array: [1, 2, 3],
      }
    end

    specify { expect(decorator.call(input)).to eq(formatted_output) }
  end
end
