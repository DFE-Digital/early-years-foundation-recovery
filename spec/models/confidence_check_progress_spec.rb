require 'rails_helper'

RSpec.describe ConfidenceCheckProgress, type: :model do
  let(:user) { create(:user, :registered) }

  shared_examples 'handling concurrent progress creation' do |method, check_type|
    let(:attributes) { { user: user, module_name: 'alpha', check_type: check_type } }
    let(:arguments) { method == :record_skip ? attributes.except(:check_type) : attributes }

    it 'uses the existing record when another request inserts before validation' do
      stale_progress = described_class.new(attributes)
      existing_progress = nil
      allow(described_class).to receive(:find_or_initialize_by).and_call_original
      allow(described_class).to receive(:find_or_initialize_by).with(**attributes).and_return(stale_progress)
      allow(stale_progress).to receive(:save!).and_wrap_original do |original|
        existing_progress = described_class.create!(attributes)
        allow(described_class).to receive(:find_or_initialize_by).with(**attributes).and_call_original
        original.call
      end

      progress = described_class.public_send(method, **arguments)

      expect(progress).to eq existing_progress
      expect(described_class.where(attributes).count).to eq 1
      expect(progress.public_send(timestamp)).to be_present
    end

    it 'retries when another request inserts after validation' do
      stale_progress = described_class.new(attributes)
      existing_progress = nil
      allow(described_class).to receive(:find_or_initialize_by).and_call_original
      allow(described_class).to receive(:find_or_initialize_by).with(**attributes).and_return(stale_progress)
      allow(stale_progress).to receive(:save!).and_wrap_original do |original|
        existing_progress = described_class.create!(attributes)
        allow(described_class).to receive(:find_or_initialize_by).with(**attributes).and_call_original
        described_class.transaction(requires_new: true) { original.call(validate: false) }
      end

      progress = described_class.public_send(method, **arguments)

      expect(progress).to eq existing_progress
      expect(described_class.where(attributes).count).to eq 1
      expect(progress.public_send(timestamp)).to be_present
    end

    it 'does not retry unrelated validation failures' do
      expect(described_class).to receive(:find_or_initialize_by).once.and_call_original

      expect {
        described_class.public_send(method, **arguments.merge(module_name: nil))
      }.to raise_error(ActiveRecord::RecordInvalid, /Module name can't be blank/)
    end

    it 'does not retry a uniqueness failure alongside other validation errors' do
      invalid_progress = described_class.new(attributes.merge(module_name: nil))
      allow(described_class).to receive(:find_or_initialize_by).and_return(invalid_progress)
      expect(invalid_progress).to receive(:save!).once do
        invalid_progress.valid?
        invalid_progress.errors.add(:module_name, :taken)
        raise ActiveRecord::RecordInvalid, invalid_progress
      end

      expect {
        described_class.public_send(method, **arguments)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      progress = described_class.new(user: user, module_name: 'alpha', check_type: 'pre')
      expect(progress).to be_valid
    end

    it 'requires a module_name' do
      progress = described_class.new(user: user, module_name: nil, check_type: 'pre')
      expect(progress).not_to be_valid
    end

    it 'requires a check_type' do
      progress = described_class.new(user: user, module_name: 'alpha', check_type: nil)
      expect(progress).not_to be_valid
    end

    it 'only accepts pre or post as check_type' do
      expect(described_class.new(user: user, module_name: 'alpha', check_type: 'pre')).to be_valid
      expect(described_class.new(user: user, module_name: 'alpha', check_type: 'post')).to be_valid
      expect(described_class.new(user: user, module_name: 'alpha', check_type: 'other')).not_to be_valid
    end

    it 'requires unique module_name and check_type per user' do
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre')
      duplicate = described_class.new(user: user, module_name: 'alpha', check_type: 'pre')
      expect(duplicate).not_to be_valid
    end

    it 'allows same module with different check_type for same user' do
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre')
      post_check = described_class.new(user: user, module_name: 'alpha', check_type: 'post')
      expect(post_check).to be_valid
    end

    it 'allows same module and check_type for different users' do
      other_user = create(:user, :registered)
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre')
      progress = described_class.new(user: other_user, module_name: 'alpha', check_type: 'pre')
      expect(progress).to be_valid
    end
  end

  describe 'scopes' do
    before do
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre', started_at: 1.hour.ago, completed_at: Time.zone.now)
      described_class.create!(user: user, module_name: 'alpha', check_type: 'post', started_at: 30.minutes.ago)
      other_user = create(:user, :registered)
      described_class.create!(user: other_user, module_name: 'bravo', check_type: 'pre', skipped_at: Time.zone.now)
    end

    describe '.pre_check' do
      it 'returns only pre check records' do
        expect(described_class.pre_check.count).to eq 2
      end
    end

    describe '.post_check' do
      it 'returns only post check records' do
        expect(described_class.post_check.count).to eq 1
      end
    end

    describe '.started' do
      it 'returns records with started_at' do
        expect(described_class.started.count).to eq 2
      end
    end

    describe '.completed' do
      it 'returns records with completed_at' do
        expect(described_class.completed.count).to eq 1
      end
    end

    describe '.skipped' do
      it 'returns records with skipped_at' do
        expect(described_class.skipped.count).to eq 1
      end
    end
  end

  describe '#time_to_completion' do
    it 'returns nil when not completed' do
      progress = described_class.new(started_at: Time.zone.now, completed_at: nil)
      expect(progress.time_to_completion).to be_nil
    end

    it 'returns seconds between start and completion' do
      started = Time.zone.now - 5.minutes
      completed = Time.zone.now
      progress = described_class.new(started_at: started, completed_at: completed)
      expect(progress.time_to_completion).to eq 300
    end
  end

  describe '.record_start' do
    let(:timestamp) { :started_at }

    include_examples 'handling concurrent progress creation', :record_start, 'pre'

    it 'creates a new record with started_at' do
      expect {
        described_class.record_start(user: user, module_name: 'alpha', check_type: 'pre')
      }.to change(described_class, :count).by(1)

      progress = described_class.last
      expect(progress.module_name).to eq 'alpha'
      expect(progress.check_type).to eq 'pre'
      expect(progress.started_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'does not update started_at if already set' do
      original_start = 1.hour.ago
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre', started_at: original_start)

      described_class.record_start(user: user, module_name: 'alpha', check_type: 'pre')

      progress = described_class.find_by(user: user, module_name: 'alpha', check_type: 'pre')
      expect(progress.started_at).to be_within(1.second).of(original_start)
    end
  end

  describe '.record_completion' do
    let(:timestamp) { :completed_at }

    include_examples 'handling concurrent progress creation', :record_completion, 'post'

    it 'creates a new record with both timestamps' do
      expect {
        described_class.record_completion(user: user, module_name: 'alpha', check_type: 'post')
      }.to change(described_class, :count).by(1)

      progress = described_class.last
      expect(progress.started_at).to be_within(1.second).of(Time.zone.now)
      expect(progress.completed_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'does not update completed_at if already set' do
      original_completion = 1.hour.ago
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre', started_at: 2.hours.ago, completed_at: original_completion)

      described_class.record_completion(user: user, module_name: 'alpha', check_type: 'pre')

      progress = described_class.find_by(user: user, module_name: 'alpha', check_type: 'pre')
      expect(progress.completed_at).to be_within(1.second).of(original_completion)
    end
  end

  describe '.record_skip' do
    let(:timestamp) { :skipped_at }

    include_examples 'handling concurrent progress creation', :record_skip, 'pre'

    it 'creates a pre check record with skipped_at' do
      expect {
        described_class.record_skip(user: user, module_name: 'alpha')
      }.to change(described_class, :count).by(1)

      progress = described_class.last
      expect(progress.check_type).to eq 'pre'
      expect(progress.skipped_at).to be_within(1.second).of(Time.zone.now)
      expect(progress.started_at).to be_nil
    end

    it 'does not update skipped_at if already set' do
      original_skip = 1.hour.ago
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre', skipped_at: original_skip)

      described_class.record_skip(user: user, module_name: 'alpha')

      progress = described_class.find_by(user: user, module_name: 'alpha', check_type: 'pre')
      expect(progress.skipped_at).to be_within(1.second).of(original_skip)
    end

    it 'does not record a skip if already completed' do
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre', started_at: 2.hours.ago, completed_at: 1.hour.ago)

      described_class.record_skip(user: user, module_name: 'alpha')

      progress = described_class.find_by(user: user, module_name: 'alpha', check_type: 'pre')
      expect(progress.skipped_at).to be_nil
    end
  end

  describe '.skipped scope' do
    it 'excludes records that were completed' do
      described_class.create!(user: user, module_name: 'alpha', check_type: 'pre', skipped_at: 1.hour.ago, completed_at: 30.minutes.ago)
      other_user = create(:user, :registered)
      described_class.create!(user: other_user, module_name: 'alpha', check_type: 'pre', skipped_at: 1.hour.ago)

      expect(described_class.skipped.count).to eq 1
      expect(described_class.skipped.first.user).to eq other_user
    end
  end
end
