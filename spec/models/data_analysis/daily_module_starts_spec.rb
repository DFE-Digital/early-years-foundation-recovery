require 'rails_helper'

RSpec.describe DataAnalysis::DailyModuleStarts do
  let(:now) { Time.zone.parse('2025-03-01 10:00:00') }
  let(:module_names) { Training::Module.ordered.reject(&:draft?).map(&:name) }
  let(:headers) { ['Date', *module_names] }

  before do
    travel_to(now)

    user = create(:user, :registered)
    create(:user_module_progress, user: user, module_name: 'charlie', started_at: Time.zone.parse('2025-01-02 12:00:00'))
    create(:user_module_progress, user: create(:user, :registered), module_name: 'alpha', started_at: Time.zone.parse('2025-02-27 08:00:00'))
    create(:user_module_progress, user: create(:user, :registered), module_name: 'alpha', started_at: Time.zone.parse('2025-02-27 09:00:00'))
    create(:user_module_progress, user: create(:user, :registered), module_name: 'bravo', started_at: Time.zone.parse('2025-02-27 10:00:00'))
    create(:user_module_progress, user: create(:user, :registered), module_name: 'alpha', started_at: Time.zone.parse('2025-03-01 09:00:00'))

    # Excluded as historical data (outside rolling 60-day window)
    create(:user_module_progress, user: create(:user, :registered), module_name: 'alpha', started_at: Time.zone.parse('2024-12-30 23:59:59'))
  end

  after do
    travel_back
  end

  it 'returns pivoted daily starts for the rolling 60-day window' do
    rows = described_class.dashboard

    expect(described_class.dashboard_headers).to eq(headers)
    expect(rows.size).to eq(60)
    expect(rows.first[:date]).to eq(Date.new(2024, 12, 31))
    expect(rows.last[:date]).to eq(Date.new(2025, 2, 28))

    january_first = rows.find { |row| row[:date] == Date.new(2025, 1, 1) }
    module_names.each do |module_name|
      expect(january_first[module_name]).to eq(0)
    end

    january_second = rows.find { |row| row[:date] == Date.new(2025, 1, 2) }
    expect(january_second['charlie']).to eq(1)

    february_twenty_seventh = rows.find { |row| row[:date] == Date.new(2025, 2, 27) }
    expect(february_twenty_seventh['alpha']).to eq(2)
    expect(february_twenty_seventh['bravo']).to eq(1)
    (module_names - %w[alpha bravo]).each do |module_name|
      expect(february_twenty_seventh[module_name]).to eq(0)
    end

    expect(rows.find { |row| row[:date] == Date.new(2025, 3, 1) }).to be_nil

    alpha_total = rows.sum { |row| row['alpha'] }
    expect(alpha_total).to eq(2)
  end
end
