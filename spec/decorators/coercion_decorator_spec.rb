require 'rails_helper'

RSpec.describe CoercionDecorator do
  subject(:decorator) { described_class.new }

  let(:input) do
    {
      float: 0.1,
      date: Time.zone.local(2023, 1, 1),
      string: 'foo',
      as_percentage: 0.1,
    }
  end

  let(:output) do
    {
      float: 0.1,
      date: '2023-01-01 00:00:00',
      string: 'foo',
      as_percentage: '10.0%',
    }
  end

  describe '.call' do
    it 'formats values' do
      expect(output).to eq decorator.call(input)
    end
  end
end
