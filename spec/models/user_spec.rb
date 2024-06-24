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

  describe 'course engagement' do
    include_context 'with progress'

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

    describe '#course_started?' do
      it 'is true once a module is started' do
        expect(user).not_to be_course_started
        start_module(alpha)
        expect(user).to be_course_started
      end
    end

    describe '#module_in_progress?' do
      it 'is true if a module is incomplete' do
        expect(user).not_to be_module_in_progress
        start_module(bravo)
        expect(user).to be_module_in_progress
        sleep(1) # time taken to complete
        complete_module(bravo)
        expect(user).not_to be_module_in_progress
      end
    end

    describe '#modules_in_progress' do
      it 'lists started modules' do
        expect(user.modules_in_progress).to be_empty
        start_module(charlie)
        expect(user.modules_in_progress).not_to be_empty
      end
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
             early_years_experience: 'na',
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
             early_years_experience: '2-5',
             module_time_to_completion: {
               alpha: 1,
               bravo: 0,
             })

      user = create(:user, :registered,
                    id: 3,
                    local_authority: 'City of London',
                    module_time_to_completion: {
                      alpha: 3,
                    },
                    notify_callback: {
                      status: 'delivered',
                    })

      Event.new(
        user: user,
        visit: Visit.new,
        name: 'user_registration',
        time: Time.zone.local(2023, 0o1, 12, 10, 15, 59),
      ).save!

      create(:user, :confirmed, id: 4)
    end

    it 'exports formatted attributes as CSV' do
      expect(described_class.to_csv(batch_size: 2)).to eq <<~CSV
        id,local_authority,setting_type,setting_type_other,role_type,role_type_other,early_years_experience,registration_complete,private_beta_registration_complete,registration_complete_any?,registered_at,terms_and_conditions_agreed_at,training_emails,early_years_emails,email_delivery_status,gov_one?,module_1_time,module_2_time,module_3_time
        1,Watford Borough Council,,DfE,other,Developer,na,true,true,true,,2000-01-01 00:00:00,true,false,unknown,true,4,2,0
        2,Leeds City Council,,DfE,Trainer or lecturer,,2-5,true,false,true,,2000-01-01 00:00:00,true,false,unknown,true,1,0,
        3,City of London,,DfE,other,Developer,,true,false,true,2023-01-12 10:15:59,2000-01-01 00:00:00,true,false,delivered,true,3,,
        4,,,,,,,false,false,false,,2000-01-01 00:00:00,,,unknown,true,,,
      CSV
    end
  end

  describe '#redact!' do
    subject(:user) { create(:user, :registered) }

    before do
      user.mail_events.create!(template: '000')
      user.notes.create!(training_module: 'alpha', body: 'this is a note')
    end

    it 'redacts personal information' do
      expect(user.mail_events.count).to be 1
      expect(user.notes.count).to be 1
      user.redact!
      expect(user.mail_events.count).to be 0
      expect(user.notes.count).to be 0

      expect(user.gov_one_id).to start_with "#{user.id}urn:fdc:gov.uk:2022:"
      expect(user.first_name).to eq 'Redacted'
      expect(user.last_name).to eq 'User'
      expect(user.notify_callback).to be_nil
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

  describe '.new_module_mail_job_recipients' do
    subject(:user) { create(:user, :registered) }

    context 'without mail event' do
      it 'includes user' do
        expect(described_class.new_module_mail_job_recipients).to include(user)
        expect(described_class.with_new_module_mail_events).not_to include(user)
      end
    end

    context 'with mail event' do
      before do
        create :mail_event,
               user: user,
               template: NotifyMailer::TEMPLATE_IDS[:new_module],
               personalisation: { mod_number: 3 }
      end

      it 'excludes user' do
        expect(described_class.new_module_mail_job_recipients).not_to include(user)
        expect(described_class.with_new_module_mail_events).to include(user)
      end
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

    context 'without an existing account' do
      before do
        described_class.find_or_create_from_gov_one(**params)
      end

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
      before do
        described_class.find_or_create_from_gov_one(**params)
      end

      context 'and using GovOne for the first time' do
        let(:user) do
          create :user, :registered, email: email, gov_one_id: nil
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

  describe 'authentication bypass for developers' do
    let(:user) { create :user, email: 'completed@example.com' }

    describe '.test_user' do
      it 'returns the completed seeded user' do
        expect(user).to eq described_class.test_user
      end
    end

    describe '#test_user?' do
      specify { expect(user).to be_test_user }
    end
  end

  describe '#response_for' do
    subject(:response) { user.response_for(question) }

    let(:user) { create :user, :registered }
    let(:question) do
      # default formative used in factory
      Training::Module.by_name('alpha').page_by_name('1-1-4-1')
    end

    before do
      skip unless Rails.application.migrated_answers?
    end

    context 'with duplicates' do
      before do
        create :response, user: user, answers: [2], correct: false, created_at: Time.zone.local(2020, 1, 1)
        create :response, user: user, answers: [2], correct: false, created_at: Time.zone.local(2021, 1, 1)
        create :response, user: user, answers: [1], correct: true, created_at: Time.zone.local(2022, 1, 1)
      end

      it 'selects the most recent' do
        expect(response.answers).to eq [1]
      end
    end
  end
end
