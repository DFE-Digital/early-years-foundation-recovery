require 'rails_helper'

RSpec.describe DataAnalysis::DeviceEngagement do
  # One module (alpha) has completions on Desktop and Mobile with distinct durations.
  before do
    user = create(:user, :registered)

    desktop_visit = create(:visit, user_id: user.id)
    mobile_visit  = create(:visit, user_id: user.id)

    # Desktop: 12 minutes
    create(:event, user: user, visit: desktop_visit, name: 'module_start',
                   properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-01 09:00:00'))
    create(:event, user: user, visit: desktop_visit, name: 'module_complete',
                   properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-01 09:12:00'))

    # Mobile: 45 minutes
    create(:event, user: user, visit: mobile_visit, name: 'module_start',
                   properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-02 09:00:00'))
    create(:event, user: user, visit: mobile_visit, name: 'module_complete',
                   properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-02 09:45:00'))

    # Set device types on visits
    desktop_visit.update!(device_type: 'Desktop')
    mobile_visit.update!(device_type: 'Mobile')
  end

  let(:headers) do
    [
      'Module Name',
      'Device Type',
      'Started Count',
      'Completed Count',
      'Completion Rate %',
      'Average Minutes',
      'Median Minutes',
      'P90 Minutes',
    ]
  end

  let(:rows) do
    # Build 4 rows per module (Desktop, Mobile, Tablet, Other); only alpha has data
    Training::Module.ordered.reject(&:draft?).flat_map do |mod|
      %w[Desktop Mobile Tablet Other].map do |device|
        if mod.name == 'alpha' && device == 'Desktop'
          { module_name: 'alpha', device_type: 'Desktop', started_count: 1, completed_count: 1, completion_rate_percentage: 1.0, average_minutes: 12.0, median_minutes: 12.0, p90_minutes: 12.0 }
        elsif mod.name == 'alpha' && device == 'Mobile'
          { module_name: 'alpha', device_type: 'Mobile', started_count: 1, completed_count: 1, completion_rate_percentage: 1.0, average_minutes: 45.0, median_minutes: 45.0, p90_minutes: 45.0 }
        else
          { module_name: mod.name, device_type: device, started_count: 0, completed_count: 0, completion_rate_percentage: 0, average_minutes: 0, median_minutes: 0, p90_minutes: 0 }
        end
      end
    end
  end

  it_behaves_like 'a data export model'

  describe 'completion rate calculation' do
    it 'calculates completion rate for partial completions' do
      user1 = create(:user, :registered)
      user2 = create(:user, :registered)

      tablet_visit1 = create(:visit, user_id: user1.id, device_type: 'Tablet')
      tablet_visit2 = create(:visit, user_id: user2.id, device_type: 'Tablet')

      # User 1 starts but doesn't complete
      create(:event, user: user1, visit: tablet_visit1, name: 'module_start',
                     properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-03 10:00:00'))

      # User 2 starts and completes
      create(:event, user: user2, visit: tablet_visit2, name: 'module_start',
                     properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-03 11:00:00'))
      create(:event, user: user2, visit: tablet_visit2, name: 'module_complete',
                     properties: { training_module_id: 'alpha' }, time: Time.zone.parse('2025-01-03 11:30:00'))

      result = described_class.dashboard
      tablet_alpha = result.find { |r| r[:module_name] == 'alpha' && r[:device_type] == 'Tablet' }

      expect(tablet_alpha[:started_count]).to eq(2)
      expect(tablet_alpha[:completed_count]).to eq(1)
      expect(tablet_alpha[:completion_rate_percentage]).to eq(0.5)
      expect(tablet_alpha[:average_minutes]).to eq(30.0)
    end
  end
end
