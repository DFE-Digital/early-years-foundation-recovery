require 'rails_helper'

RSpec.describe ContentIntegrity do
  context 'when module is not specified' do
    it 'raises constraint error' do
      expect { described_class.new(module_name: nil) }.to raise_error Dry::Types::ConstraintError
    end
  end

  describe '#valid?' do
    context 'when valid' do
      specify { expect(described_class.new(module_name: 'alpha')).to be_valid }
      specify { expect(described_class.new(module_name: 'bravo')).to be_valid }
      specify { expect(described_class.new(module_name: 'charlie')).to be_valid }
    end

    context 'when invalid' do
      specify { expect(described_class.new(module_name: 'delta')).not_to be_valid }
    end
  end
end
