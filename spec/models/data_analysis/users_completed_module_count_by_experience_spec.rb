# spec/models/data_analysis/users_completed_module_count_by_experience_spec.rb
require 'rails_helper'

RSpec.describe DataAnalysis::UsersCompletedModuleCountByExperience do
  let(:headers) do
    %w[
      Experience
      ModulesCompleted
      UserCount
    ]
  end

  let(:rows) do
    [
      { experience: '0-2', modules_completed: 0, user_count: 1 },
      { experience: '0-2', modules_completed: 1, user_count: 2 },
      { experience: '0-2', modules_completed: 2, user_count: 1 },
      { experience: '3-5', modules_completed: 0, user_count: 1 },
      { experience: '3-5', modules_completed: 1, user_count: 1 },
      { experience: '5+',  modules_completed: 3, user_count: 1 },
      { experience: 'na', modules_completed: 0, user_count: 1 },
    ]
  end

  before do
    # Experience 0-2
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => nil, 'Module 2' => nil }) # 0 completed
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => nil }) # 1 completed
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => nil }) # 1 completed
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => Time.zone.now }) # 2 completed

    # Experience 3-5
    create(:user, early_years_experience: '3-5',
                  module_time_to_completion: { 'Module 1' => nil }) # 0 completed
    create(:user, early_years_experience: '3-5',
                  module_time_to_completion: { 'Module 1' => Time.zone.now }) # 1 completed

    # Experience 5+
    create(:user, early_years_experience: '5+',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => Time.zone.now, 'Module 3' => Time.zone.now }) # 3 completed

    # Experience na
    create(:user, early_years_experience: 'na',
                  module_time_to_completion: { 'Module 1' => nil }) # 0 completed
  end

  it_behaves_like 'a data export model'

  describe '.completed_modules_count' do
    it 'counts only modules that are present (completed)' do
      user = build(:user, module_time_to_completion: {
        'Module 1' => Time.zone.now,
        'Module 2' => nil,
        'Module 3' => Time.zone.now,
      })

      expect(described_class.send(:completed_modules_count, user)).to eq(2)
    end

    it 'returns 0 if no modules are completed' do
      user = build(:user, module_time_to_completion: {
        'Module 1' => nil,
        'Module 2' => nil,
      })

      expect(described_class.send(:completed_modules_count, user)).to eq(0)
    end
  end

  describe '.counts_by_experience' do
    it 'groups users correctly by experience and completed modules' do
      counts = described_class.send(:counts_by_experience)

      expect(counts['0-2'][0]).to eq(1)  # one user completed 0 modules
      expect(counts['0-2'][1]).to eq(2)  # two users completed 1 module
      expect(counts['0-2'][2]).to eq(1)  # one user completed 2 modules
      expect(counts['3-5'][0]).to eq(1)
      expect(counts['3-5'][1]).to eq(1)
      expect(counts['5+'][3]).to eq(1)
      expect(counts['na'][0]).to eq(1)
    end
  end

  describe '.all_users' do
    it 'returns only users without closed_at set' do
      active_user = create(:user, closed_at: nil)
      inactive_user = create(:user, closed_at: Time.zone.now)

      expect(described_class.send(:all_users)).to include(active_user)
      expect(described_class.send(:all_users)).not_to include(inactive_user)
    end
  end
end
