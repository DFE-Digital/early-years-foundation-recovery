require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#first_name' do
    it 'must be present' do
      expect(build(:user, :registered)).to be_valid
      expect(build(:user, :registered, first_name: nil)).not_to be_valid
    end
  end

  describe '#last_name' do
    it 'must be present' do
      expect(build(:user, :registered)).to be_valid
      expect(build(:user, :registered, last_name: nil)).not_to be_valid
    end
  end

  describe '#postcode' do
    it 'must be a valid' do
      expect(build(:user, postcode: '')).not_to be_valid
      expect(build(:user, postcode: 'foo')).not_to be_valid
      expect(build(:user, postcode: 'wd180dn')).to be_valid
    end

    it 'is normalised' do
      expect(build(:user, postcode: 'wd180dn').postcode).to eq 'WD18 0DN'
    end
  end

  describe '#ofsted_number' do
    it 'must be a valid' do
      expect(build(:user, ofsted_number: nil)).to be_valid
      expect(build(:user, ofsted_number: 'EY123456')).to be_valid
      expect(build(:user, ofsted_number: 'vc123456')).to be_valid
      expect(build(:user, ofsted_number: '1234567')).to be_valid
      expect(build(:user, ofsted_number: '123456')).to be_valid
      expect(build(:user, ofsted_number: 'foo')).not_to be_valid
    end

    it 'is normalised' do
      user = create(:user, ofsted_number: 'vc123456')
      expect(user.ofsted_number).to eq 'VC123456'
    end
  end
end
