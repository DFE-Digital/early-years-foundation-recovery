require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid after registration' do
    expect(build(:user, :registered)).to be_valid
  end

  describe '#first_name' do
    it 'must be present' do
      expect(build(:user, :registered, first_name: nil)).not_to be_valid
    end
  end

  describe '#last_name' do
    it 'must be present' do
      expect(build(:user, :registered, last_name: nil)).not_to be_valid
    end
  end

  describe '#setting_type' do
    it 'must be present' do
      expect(build(:user, :registered, setting_type: nil)).not_to be_valid
    end
  end

  describe '#role_type' do
    it 'must be present' do
      expect(build(:user, :registered, role_type: nil)).not_to be_valid
    end
  end

  describe '#course' do
    subject(:user) { create(:user, :registered) }

    it 'provides modules by state' do
      expect(user.course.current_modules).to be_an Array
      expect(user.course.available_modules).to be_an Array
      expect(user.course.upcoming_modules).to be_an Array
      expect(user.course.completed_modules).to be_an Array
    end
  end
end
