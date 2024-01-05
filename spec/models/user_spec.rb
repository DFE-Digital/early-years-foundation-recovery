require 'rails_helper'

# @return [String]
# def random_password
#   special_characters = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+']
#   password = SecureRandom.alphanumeric(5).upcase + SecureRandom.alphanumeric(5).downcase + special_characters.sample(3).join + SecureRandom.hex(5)
# end

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
    subject(:user) do
      build(:user, :registered, setting_type_id: setting, role_type: nil)
    end

    context 'when setting is other' do
      let(:setting) { 'other' }

      it 'role must be present' do
        expect(user).not_to be_valid
      end
    end

    context 'when setting is childminder' do
      let(:setting) { 'childminder' }

      it 'role must be present' do
        expect(user).not_to be_valid
      end
    end

    %w[
      training_provider
      central_government
      department_for_education
      local_authority
    ].each do |setting|
      context "when setting is #{setting}" do
        let(:setting) { setting }

        it 'role is not required' do
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
      expect(user.module_ttc).to eq({ 'alpha' => 4, 'bravo' => 2, 'charlie' => nil })
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
             role_type_other: nil,
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
      expect(described_class.to_csv(batch_size: 2)).to eq <<~CSV
        id,local_authority,setting_type,setting_type_other,role_type,role_type_other,registration_complete,private_beta_registration_complete,registration_complete_any?,registered_at,terms_and_conditions_agreed_at,module_1_time,module_2_time,module_3_time
        1,Watford Borough Council,,DfE,other,Developer,true,true,true,,2000-01-01 00:00:00,4,2,0
        2,Leeds City Council,,DfE,Trainer or lecturer,,true,false,true,,2000-01-01 00:00:00,1,0,
        3,City of London,,DfE,other,Developer,true,false,true,2023-01-12 10:15:59,2000-01-01 00:00:00,3,,
        4,,,,,,false,false,false,,2000-01-01 00:00:00,,,
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
      expect(user.valid_password?('RedactedUser12!@')).to eq true
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

    it 'filters by user progress state' do
      expect(user.active_modules.map(&:name)).to eq %w[alpha bravo]
    end
  end

  describe 'learning log' do
    subject(:user) { create(:user, :registered) }

    context 'with notes' do
      before { create(:note, user: user) }

      it '#notes? is true' do
        expect(user).to be_notes
      end

      it '#with_notes includes the user' do
        expect(described_class.with_notes).to include(user)
      end

      it '#without_notes excludes the user' do
        expect(described_class.without_notes).not_to include(user)
      end
    end

    context 'without notes' do
      it '#notes? is false' do
        expect(user).not_to be_notes
      end

      it '#with_notes excludes the user' do
        expect(described_class.with_notes).not_to include(user)
      end

      it '#without_notes includes the user' do
        expect(described_class.without_notes).to include(user)
      end
    end
  end

  describe '.find_or_create_from_gov_one' do
    let(:email) { 'current@test.com' }
    let(:gov_one_id) { 'urn:fdc:gov.uk:2022:23-random-alpha-numeric' }

    before do
      described_class.find_or_create_from_gov_one(**params)
    end

    context 'without an existing account' do
      let(:params) do
        { email: email, gov_one_id: gov_one_id }
      end

      it 'creates a new user' do
        expect(described_class.count).to eq 1
        expect(described_class.first.email).to eq params[:email]
        expect(described_class.first.gov_one_id).to eq params[:gov_one_id]
      end
    end

    context 'with an existing account' do
      context 'and using GovOne for the first time' do
        let(:user) do
          create :user, :registered, email: email
        end

        let(:params) do
          { email: user.email, gov_one_id: gov_one_id }
        end

        it 'associates GovOne ID' do
          expect(user.reload.gov_one_id).to eq gov_one_id
        end
      end

      context 'and using GovOne with a new email' do
        let(:user) do
          create :user, :registered, email: 'old@test.com', gov_one_id: gov_one_id
        end

        let(:params) do
          { email: email, gov_one_id: user.gov_one_id }
        end

        it 'updates email' do
          expect(user.reload.email).to eq email
        end
      end
    end
  end

  describe '.random_password' do
    it 'generates a valid password' do
      expect(described_class.random_password).to be_a String
      expect(described_class.random_password.scan(/[A-Z]/).count).to be >= 2
      expect(described_class.random_password.scan(/[a-z]/).count).to be >= 2
      expect(described_class.random_password.scan(/[0-9]/).count).to be >= 2
      expect(described_class.random_password.scan(/[^A-Za-z0-9]/).count).to be >= 2
    end
  end
end
