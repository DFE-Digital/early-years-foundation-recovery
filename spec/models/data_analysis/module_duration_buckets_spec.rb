require 'rails_helper'

RSpec.describe DataAnalysis::ModuleDurationBuckets do
  before do
    user = create(:user, :registered)
    visit1 = create(:visit, user_id: user.id)
    visit2 = create(:visit, user_id: user.id)
    visit3 = create(:visit, user_id: user.id)

    create(:event,
           user: user,
           visit: visit1,
           name: 'module_start',
           properties: { training_module_id: 'alpha' },
           time: Time.zone.parse('2025-01-01 10:00:00'))
    create(:event,
           user: user,
           visit: visit1,
           name: 'module_complete',
           properties: { training_module_id: 'alpha' },
           time: Time.zone.parse('2025-01-01 10:10:00')) # +10m

    create(:event,
           user: user,
           visit: visit2,
           name: 'module_start',
           properties: { training_module_id: 'alpha' },
           time: Time.zone.parse('2025-01-02 10:00:00'))
    create(:event,
           user: user,
           visit: visit2,
           name: 'module_complete',
           properties: { training_module_id: 'alpha' },
           time: Time.zone.parse('2025-01-02 10:25:00')) # +25m

    create(:event,
           user: user,
           visit: visit3,
           name: 'module_start',
           properties: { training_module_id: 'alpha' },
           time: Time.zone.parse('2025-01-03 10:00:00'))
    create(:event,
           user: user,
           visit: visit3,
           name: 'module_complete',
           properties: { training_module_id: 'alpha' },
           time: Time.zone.parse('2025-01-03 11:10:00')) # +70m
  end

  let(:headers) do
    [
      'Module Name',
      'Completed Count',
      'Average Minutes',
      'Median Minutes',
      'P90 Minutes',
      '0-20 minutes',
      '21-30 minutes',
      '31-45 minutes',
      '46-60 minutes',
      'Over 60 minutes',
    ]
  end

  let(:rows) do
    mods = Training::Module.ordered.reject(&:draft?)

    mods.map do |mod|
      if mod.name == 'alpha'
        {
          module_name: 'alpha',
          completed_count: 3,
          average_minutes: 35.0,
          median_minutes: 25.0,
          p90_minutes: 61.0,
          '0_20_minutes': 1,
          '21_30_minutes': 1,
          '31_45_minutes': 0,
          '46_60_minutes': 0,
          'over_60_minutes': 1,
        }
      else
        {
          module_name: mod.name,
          completed_count: 0,
          average_minutes: 0,
          median_minutes: 0,
          p90_minutes: 0,
          '0_20_minutes': 0,
          '21_30_minutes': 0,
          '31_45_minutes': 0,
          '46_60_minutes': 0,
          'over_60_minutes': 0,
        }
      end
    end
  end

  it_behaves_like 'a data export model'
end
