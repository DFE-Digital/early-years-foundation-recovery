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

  describe '.record_page_view' do
    it 'creates a new record with page in visited_pages' do
      expect {
        described_class.record_page_view(user: user, module_name: 'alpha', page_name: 'what-to-expect')
      }.to change(described_class, :count).by(1)

      progress = described_class.last
      expect(progress.module_name).to eq 'alpha'
      expect(progress.started_at).to be_within(1.second).of(Time.zone.now)
      expect(progress.visited_pages).to have_key('what-to-expect')
      expect(progress.last_page).to eq 'what-to-expect'
    end

    it 'adds pages to existing record' do
      described_class.record_page_view(user: user, module_name: 'alpha', page_name: 'what-to-expect')
      described_class.record_page_view(user: user, module_name: 'alpha', page_name: '1-1')

      progress = described_class.find_by(user: user, module_name: 'alpha')
      expect(progress.visited_pages.keys).to contain_exactly('what-to-expect', '1-1')
      expect(progress.last_page).to eq '1-1'
    end

    it 'does not overwrite existing page timestamp' do
      described_class.record_page_view(user: user, module_name: 'alpha', page_name: 'what-to-expect')
      original_time = described_class.last.visited_pages['what-to-expect']

      travel_to 1.hour.from_now do
        described_class.record_page_view(user: user, module_name: 'alpha', page_name: 'what-to-expect')
      end

      progress = described_class.find_by(user: user, module_name: 'alpha')
      expect(progress.visited_pages['what-to-expect']).to eq original_time
    end
  end

  describe '#visited?' do
    let(:progress) do
      described_class.create!(
        user: user,
        module_name: 'alpha',
        started_at: Time.zone.now,
        visited_pages: { 'what-to-expect' => Time.zone.now.iso8601 },
      )
    end

    it 'returns true for visited pages' do
      expect(progress.visited?('what-to-expect')).to be true
    end

    it 'returns false for unvisited pages' do
      expect(progress.visited?('1-1')).to be false
    end
  end

  describe '#visited_page_names' do
    it 'returns array of visited page names' do
      progress = described_class.create!(
        user: user,
        module_name: 'alpha',
        started_at: Time.zone.now,
        visited_pages: { 'what-to-expect' => Time.zone.now.iso8601, '1-1' => Time.zone.now.iso8601 },
      )

      expect(progress.visited_page_names).to contain_exactly('what-to-expect', '1-1')
    end

    it 'returns empty array when no pages visited' do
      progress = described_class.create!(user: user, module_name: 'alpha', started_at: Time.zone.now)
      expect(progress.visited_page_names).to eq []
    end
  end

  describe '#visited_pages_count' do
    it 'returns count of visited pages' do
      progress = described_class.create!(
        user: user,
        module_name: 'alpha',
        started_at: Time.zone.now,
        visited_pages: { 'what-to-expect' => Time.zone.now.iso8601, '1-1' => Time.zone.now.iso8601 },
      )

      expect(progress.visited_pages_count).to eq 2
    end

    it 'returns 0 when no pages visited' do
      progress = described_class.create!(user: user, module_name: 'alpha', started_at: Time.zone.now)
      expect(progress.visited_pages_count).to eq 0
    end
  end

  describe '.migrate_from_events' do
    let(:module_name) { 'alpha' }
    let(:start_time) { 2.days.ago }
    let(:complete_time) { 1.day.ago }
    let(:page_view_time) { 2.days.ago + 1.hour }

    context 'when user has page view events' do
      before do
        visit = create(:visit, user: user)
        create(:event, user: user, visit: visit, name: 'module_content_page',
                       properties: { 'training_module_id' => module_name, 'id' => 'what-to-expect' }, time: page_view_time)
        create(:event, user: user, visit: visit, name: 'module_content_page',
                       properties: { 'training_module_id' => module_name, 'id' => '1-1' }, time: page_view_time + 1.minute)
      end

      it 'creates a progress record with visited_pages from event data' do
        expect {
          described_class.migrate_from_events(user: user, module_name: module_name)
        }.to change(described_class, :count).by(1)

        progress = described_class.find_by(user: user, module_name: module_name)
        expect(progress.visited_pages).to have_key('what-to-expect')
        expect(progress.visited_pages).to have_key('1-1')
        expect(progress.last_page).to eq '1-1'
      end

      it 'uses first page view time as started_at when no module_start event' do
        described_class.migrate_from_events(user: user, module_name: module_name)

        progress = described_class.find_by(user: user, module_name: module_name)
        expect(progress.started_at).to be_within(1.second).of(page_view_time)
      end
    end

    context 'when user has module_start, page views, and module_complete events' do
      before do
        visit = create(:visit, user: user)
        create(:event, user: user, visit: visit, name: 'module_start',
                       properties: {
                         'training_module_id' => module_name,
                         'path' => "/modules/#{module_name}/content-pages/what-to-expect",
                         'controller' => 'training/pages',
                         'action' => 'show',
                         'id' => 'what-to-expect',
                       }, time: start_time)
        create(:event, user: user, visit: visit, name: 'module_content_page',
                       properties: { 'training_module_id' => module_name, 'id' => 'what-to-expect' }, time: start_time + 1.minute)
        create(:event, user: user, visit: visit, name: 'module_complete',
                       properties: {
                         'training_module_id' => module_name,
                         'path' => "/modules/#{module_name}/content-pages/certificate",
                         'controller' => 'training/pages',
                         'action' => 'show',
                         'id' => 'certificate',
                       }, time: complete_time)
      end

      it 'creates a progress record with all data' do
        described_class.migrate_from_events(user: user, module_name: module_name)

        progress = described_class.find_by(user: user, module_name: module_name)
        expect(progress.started_at).to be_within(1.second).of(start_time)
        expect(progress.completed_at).to be_within(1.second).of(complete_time)
        expect(progress.visited_pages).to have_key('what-to-expect')
      end
    end

    context 'when user has no events for this module' do
      it 'does not create a record' do
        expect {
          described_class.migrate_from_events(user: user, module_name: module_name)
        }.not_to change(described_class, :count)
      end
    end

    context 'when user already has a progress record' do
      before do
        described_class.create!(user: user, module_name: module_name, started_at: Time.zone.now)
        visit = create(:visit, user: user)
        create(:event, user: user, visit: visit, name: 'module_content_page',
                       properties: { 'training_module_id' => module_name, 'id' => 'what-to-expect' }, time: start_time)
      end

      it 'does not create a duplicate record' do
        expect {
          described_class.migrate_from_events(user: user, module_name: module_name)
        }.not_to change(described_class, :count)
      end

      it 'backfills missing visited_pages into the existing record' do
        progress = described_class.find_by(user: user, module_name: module_name)
        expect(progress.visited_pages_count).to eq 0

        described_class.migrate_from_events(user: user, module_name: module_name)

        progress.reload
        expect(progress.visited_pages).to have_key('what-to-expect')
      end
    end
  end
end
