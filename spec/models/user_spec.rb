require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#ofsted_number' do
    it 'must be a valid' do
      expect(build(:user, ofsted_number: nil)).to be_valid
      expect(build(:user, ofsted_number: 'EY123456')).to be_valid
      expect(build(:user, ofsted_number: 'vc123456')).to be_valid
      expect(build(:user, ofsted_number: '12345678')).to be_valid
      expect(build(:user, ofsted_number: 'foo')).not_to be_valid
    end
  end
end
