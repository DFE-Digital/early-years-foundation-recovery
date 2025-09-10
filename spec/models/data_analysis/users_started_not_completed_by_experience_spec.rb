# spec/models/data_analysis/users_started_not_completed_by_experience_spec.rb
require 'rails_helper'

RSpec.describe DataAnalysis::UsersStartedNotCompletedByExperience do
  let(:headers) { %w[ModuleName Experience UserCount] }

  let(:experience_0_2_years) { '0-2' }
  let(:experience_3_5_years) { '3-5' }
  let(:experience_5_plus_years) { '5+' }

  let(:rows) do
    [
      { module_name: 'Module 1', experience: '0-2', user_count: 2 },
      { module_name: 'Module 1', experience: '3-5', user_count: 1 },
      { module_name: 'Module 1', experience: '5+', user_count: 1 },
      { module_name: 'Module 2', experience: '0-2', user_count: 1 },
      { module_name: 'Module 2', experience: '3-5', user_count: 1 },
      { module_name: 'Module 2', experience: 'Unknown', user_count: 1 },
    ]
  end

  before do
    # Users in 0-2 experience
    create(:user, early_years_experience: experience_0_2_years,
                  module_time_to_completion: {
                    'Module 1' => 0,
                    'Module 2' => 120,
                  })
    create(:user, early_years_experience: experience_0_2_years,
                  module_time_to_completion: { 'Module 1' => 0 })
    create(:user, early_years_experience: experience_0_2_years,
                  module_time_to_completion: { 'Module 2' => 0 })

    # Users in 3-5 experience
    create(:user, early_years_experience: experience_3_5_years,
                  module_time_to_completion: { 'Module 1' => 0 })
    create(:user, early_years_experience: experience_3_5_years,
                  module_time_to_completion: { 'Module 2' => 0 })

    # Users in 5+ experience
    create(:user, early_years_experience: experience_5_plus_years,
                  module_time_to_completion: { 'Module 1' => 0 })

    # User with nil experience
    create(:user, early_years_experience: nil,
                  module_time_to_completion: { 'Module 2' => 0 })
  end

  it_behaves_like 'a data export model'

  describe '.not_completed_modules' do
    it 'returns only modules with zero completion time' do
      user = build(:user, module_time_to_completion: {
        'Module A' => 0,
        'Module B' => 200,
        'Module C' => nil,
      })

      result = described_class.send(:not_completed_modules, user)

      expect(result).to contain_exactly('Module A', 'Module C')
    end
  end

  describe '.per_user_module_status' do
    it 'returns module and experience pairs for incomplete modules' do
      # Clear out other users created by the before block
      User.delete_all

      create(:user, early_years_experience: '0-2',
                    module_time_to_completion: {
                      'Module X' => 0,
                      'Module Y' => 10,
                    })

      result = described_class.send(:per_user_module_status)

      expect(result).to include(
        { module_name: 'Module X', experience: '0-2' },
      )
      expect(result).not_to include(
        { module_name: 'Module Y', experience: '0-2' },
      )
    end
  end
end
