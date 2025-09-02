# spec/models/data_analysis/users_module_order_by_experience_spec.rb
require 'rails_helper'

RSpec.describe DataAnalysis::UsersModuleOrderByExperience do
  let(:headers) do
    %w[
      Experience
      ModuleName
      Module_Started_First
      Module_Started_Second
      Module_Started_Third
    ]
  end

  let(:rows) do
    described_class.dashboard
  end

  let!(:user_bob) { create(:user, early_years_experience: 1) }
  let!(:user_john) { create(:user, early_years_experience: 3) }
  let!(:user_jane) { create(:user, early_years_experience: 7) }
  let!(:user_ann) { create(:user, early_years_experience: 10) }
  let!(:user_no_experience) { create(:user, early_years_experience: nil) }

  before do
    # User bob: Less than 2 years
    create(:event, user: user_bob, name: 'module_start',
                   properties: { 'training_module_id' => 'child-development-and-the-eyfs' },
                   time: 3.hours.ago) # Module 1 first
    create(:event, user: user_bob, name: 'module_start',
                   properties: { 'training_module_id' => 'brain-development-and-how-children-learn' },
                   time: 2.hours.ago) # Module 2 second
    create(:event, user: user_bob, name: 'module_start',
                   properties: { 'training_module_id' => 'personal-social-and-emotional-development' },
                   time: 1.hour.ago) # Module 3 third

    # User john: Between 2 and 5 years
    create(:event, user: user_john, name: 'module_start',
                   properties: { 'training_module_id' => 'personal-social-and-emotional-development' },
                   time: 1.hour.ago) # Module 3 first

    # User jane: Between 6 and 9 years
    create(:event, user: user_jane, name: 'module_start',
                   properties: { 'training_module_id' => 'module-5' },
                   time: 2.hours.ago) # Module 5 first
    create(:event, user: user_jane, name: 'module_start',
                   properties: { 'training_module_id' => 'module-4' },
                   time: 1.hour.ago) # Module 4 second

    # User ann: 10 years or more
    create(:event, user: user_ann, name: 'module_start',
                   properties: { 'training_module_id' => 'module-7' },
                   time: 4.hours.ago) # Module 7 first
    create(:event, user: user_ann, name: 'module_start',
                   properties: { 'training_module_id' => 'module-8' },
                   time: 3.hours.ago) # Module 8 second
    create(:event, user: user_ann, name: 'module_start',
                   properties: { 'training_module_id' => 'child-development-and-the-eyfs' },
                   time: 2.hours.ago) # Module 1 third

    # User with no experience should not appear in results
    create(:event, user: user_no_experience, name: 'module_start',
                   properties: { 'training_module_id' => 'module-7' },
                   time: 1.hour.ago)
  end

  describe '.dashboard' do
    it 'returns correct counts for first, second, third modules' do
      result = described_class.dashboard

      # Less than 2 years, Module 1
      band1_module1 = result.find { |r| r[:experience] == 'Less than 2 years' && r[:module_name] == 'Module 1' }
      expect(band1_module1['Module Started First']).to eq(1)

      # Between 6 and 9 years, Module 4
      band3_module4 = result.find { |r| r[:experience] == 'Between 6 and 9 years' && r[:module_name] == 'Module 4' }
      expect(band3_module4['Module Started Second']).to eq(1)

      # Between 6 and 9 years, Module 5
      band3_module5 = result.find { |r| r[:experience] == 'Between 6 and 9 years' && r[:module_name] == 'Module 5' }
      expect(band3_module5['Module Started First']).to eq(1)

      # 10 years or more, Module 7
      band4_module7 = result.find { |r| r[:experience] == '10 years or more' && r[:module_name] == 'Module 7' }
      expect(band4_module7['Module Started First']).to eq(1)

      # 10 years or more, Module 8
      band4_module8 = result.find { |r| r[:experience] == '10 years or more' && r[:module_name] == 'Module 8' }
      expect(band4_module8['Module Started Second']).to eq(1)

      # 10 years or more, Module 1
      band4_module1 = result.find { |r| r[:experience] == '10 years or more' && r[:module_name] == 'Module 1' }
      expect(band4_module1['Module Started Third']).to eq(1)

      # Ensure users with no experience are excluded
      expect(result).to(be_none { |r| r[:experience].nil? })
    end
  end

  describe '.to_csv' do
    it 'produces a CSV with correct counts and headers' do
      csv = described_class.to_csv
      expect(csv).to include('Experience,ModuleName,Module_Started_First,Module_Started_Second,Module_Started_Third')
      expect(csv).to include('Less than 2 years,Module 1,1,0,0')
      expect(csv).to include('Between 6 and 9 years,Module 4,0,1,0')
      expect(csv).to include('Between 6 and 9 years,Module 5,1,0,0')
      expect(csv).to include('10 years or more,Module 7,1,0,0')
      expect(csv).to include('10 years or more,Module 8,0,1,0')
      expect(csv).to include('10 years or more,Module 1,0,0,1')
    end
  end

  it_behaves_like 'a data export model'
end
