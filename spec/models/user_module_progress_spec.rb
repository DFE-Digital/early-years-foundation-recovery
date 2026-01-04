require 'rails_helper'

RSpec.describe UserModuleProgress, type: :model do
  let(:user) { create(:user, :registered) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      progress = described_class.new(user: user, module_name: 'alpha', started_at: Time.zone.now)
      expect(progress).to be_valid
    end

    it 'requires a module_name' do
      progress = described_class.new(user: user, module_name: nil)
      expect(progress).not_to be_valid
    end

    it 'requires unique module_name per user' do
      described_class.create!(user: user, module_name: 'alpha', started_at: Time.zone.now)
      duplicate = described_class.new(user: user, module_name: 'alpha')
      expect(duplicate).not_to be_valid
    end

    it 'allows same module_name for different users' do
      other_user = create(:user, :registered)
      described_class.create!(user: user, module_name: 'alpha', started_at: Time.zone.now)
      progress = described_class.new(user: other_user, module_name: 'alpha', started_at: Time.zone.now)
      expect(progress).to be_valid
    end
  end

  describe 'scopes' do
    before do
      described_class.create!(user: user, module_name: 'alpha', started_at: 1.day.ago, completed_at: Time.zone.now)
      described_class.create!(user: user, module_name: 'bravo', started_at: 1.hour.ago)
    end

    describe '.started' do
      it 'returns records with started_at' do
        expect(described_class.started.count).to eq 2
      end
    end

    describe '.completed' do
      it 'returns records with completed_at' do
        expect(described_class.completed.count).to eq 1
        expect(described_class.completed.first.module_name).to eq 'alpha'
      end
    end

    describe '.in_progress' do
      it 'returns started but not completed records' do
        expect(described_class.in_progress.count).to eq 1
        expect(described_class.in_progress.first.module_name).to eq 'bravo'
      end
    end
  end

  describe '#time_to_completion' do
    it 'returns nil when not completed' do
      progress = described_class.new(started_at: Time.zone.now, completed_at: nil)
      expect(progress.time_to_completion).to be_nil
    end

    it 'returns seconds between start and completion' do
      started = Time.zone.now - 1.hour
      completed = Time.zone.now
      progress = described_class.new(started_at: started, completed_at: completed)
      expect(progress.time_to_completion).to eq 3600
    end
  end

  describe '.record_start' do
    it 'creates a new record with started_at' do
      expect {
        described_class.record_start(user: user, module_name: 'alpha')
      }.to change(described_class, :count).by(1)

      progress = described_class.last
      expect(progress.module_name).to eq 'alpha'
      expect(progress.started_at).to be_within(1.second).of(Time.zone.now)
      expect(progress.completed_at).to be_nil
    end

    it 'does not update started_at if already set' do
      original_start = 1.day.ago
      described_class.create!(user: user, module_name: 'alpha', started_at: original_start)

      described_class.record_start(user: user, module_name: 'alpha')

      progress = described_class.find_by(user: user, module_name: 'alpha')
      expect(progress.started_at).to be_within(1.second).of(original_start)
    end
  end

  describe '.record_completion' do
    it 'creates a new record with both timestamps if not exists' do
      expect {
        described_class.record_completion(user: user, module_name: 'alpha')
      }.to change(described_class, :count).by(1)

      progress = described_class.last
      expect(progress.started_at).to be_within(1.second).of(Time.zone.now)
      expect(progress.completed_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'updates completed_at on existing record' do
      original_start = 1.day.ago
      described_class.create!(user: user, module_name: 'alpha', started_at: original_start)

      described_class.record_completion(user: user, module_name: 'alpha')

      progress = described_class.find_by(user: user, module_name: 'alpha')
      expect(progress.started_at).to be_within(1.second).of(original_start)
      expect(progress.completed_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'does not update completed_at if already set' do
      original_completion = 1.day.ago
      described_class.create!(user: user, module_name: 'alpha', started_at: 2.days.ago, completed_at: original_completion)

      described_class.record_completion(user: user, module_name: 'alpha')

      progress = described_class.find_by(user: user, module_name: 'alpha')
      expect(progress.completed_at).to be_within(1.second).of(original_completion)
    end
  end
end
