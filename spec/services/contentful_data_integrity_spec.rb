require 'rails_helper'

RSpec.describe ContentfulDataIntegrity do
  let(:mod) { 'alpha' }
  subject(:data_integrity) { described_class.new(environment: 'test', training_module: mod, cached: true)}

  subject(:video_page) { Training::Video }
  
  context 'when module does not exist' do
    let(:mod) { 'foo' }
    
    it 'returns false' do
      expect(data_integrity.valid?).to be false
    end
  end
end
