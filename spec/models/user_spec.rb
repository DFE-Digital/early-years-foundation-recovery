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

    it 'must be in list' do
      expect(build(:user, :registered, setting_type_id: 'wrong')).not_to be_valid
    end
  end

  describe '#role_type' do
    context 'with childminder and other require a role type' do
      SettingType.role_type_required.each do |setting_type|
        it 'must be present' do
          expect(build(:user, :registered, setting_type_id: setting_type.id, role_type: nil)).not_to be_valid
        end
      end
    end

    context 'with none' do
      SettingType.none.each do |setting|
        it 'is not required' do
          user = build(:user, :registered, setting_type_id: setting.id, role_type: nil)
          expect(user).to be_valid
        end
      end
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

  describe '#module_ttc' do
    subject(:user) do
      create(:user,
             module_time_to_completion: {
               foo: 9,
               bravo: 2,
               alpha: 4,
             })
    end

    it 'lists seconds taken to complete published modules in order' do
      expect(user.module_ttc).to eq [4, 2, nil] # alpha, bravo, charlie
    end
  end

  # describe '#registered_at' do
  # end

  describe '.to_csv' do

    before do
      described_class.delete_all

      create(:user, :registered,
             private_beta_registration_complete: true,
             id: 1,
             local_authority: 'Watford Borough Council',
             module_time_to_completion: {
               alpha: 4,
               bravo: 2,
               charlie: 0,
             })

      create(:user, :registered,
             id: 2,
             local_authority: 'Leeds City Council',
             role_type: 'Trainer or lecturer',
             module_time_to_completion: {
               alpha: 1,
               bravo: 0,
             })

      user = create(:user, :registered,
                    id: 3,
                    local_authority: 'City of London',
                    module_time_to_completion: {
                      alpha: 3,
                    })

      Ahoy::Event.new(
        user: user,
        visit: Ahoy::Visit.new,
        name: 'user_registration',
        time: Time.zone.local(2023, 0o1, 12, 10, 15, 59),
      ).save!

      create(:user, :confirmed, id: 4)
    end

    it 'exports formatted attributes as CSV' do
      expect(described_class.to_csv).to eq <<~CSV
        id,local_authority,setting_type,role_type,registration_complete,private_beta_registration_complete,registration_complete_any,registered_at,module_1_time,module_2_time,module_3_time
        1,Watford Borough Council,,Childminder,true,true,true,,4,2,0
        2,Leeds City Council,,Trainer or lecturer,true,false,true,,1,0,
        3,City of London,,Childminder,true,false,true,2023-01-12 10:15:59 UTC,3,,
        4,,,,false,false,false,,,,
      CSV
    end
  end

  describe '#redact!' do
    subject(:user) { create(:user, :registered) }

    it 'redacts personal information' do
      user.redact!

      expect(user.first_name).to eq 'Redacted'
      expect(user.last_name).to eq 'User'
      expect(user.email).to eq "redacted_user#{user.id}@example.com"
      expect(user.valid_password?('redacteduser')).to eq true
      expect(user.closed_at).to be_within(30).of(Time.zone.now)
    end
  end

  describe '#active_modules' do
    subject(:user) do
      create(:user,
             module_time_to_completion: {
               alpha: 4,
               bravo: 2,
             })
    end

    before do
      skip 'WIP' unless Rails.application.cms?
    end

    it 'filters by user progress state' do
      expect(user.active_modules.map(&:name)).to eq %w[alpha bravo]
    end
  end
end
