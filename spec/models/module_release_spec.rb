require 'rails_helper'

RSpec.describe ModuleRelease, type: :model do
  describe '.ordered' do
    include_context 'with module releases'
    it 'returns module releases in order of module position' do
      expect(described_class.ordered.map(&:module_position)).to eq([1, 2, 3])
    end
  end
end
