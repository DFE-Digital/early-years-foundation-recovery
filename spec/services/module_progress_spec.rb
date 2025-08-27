# frozen_string_literal: true

# Define the struct safely outside of any block to avoid RuboCop warnings
EventStub = Struct.new(:name, :properties, :time) unless defined?(EventStub)

require 'rails_helper'

RSpec.describe ModuleProgress do
  subject(:progress) { described_class.new(user: user, mod: alpha, user_module_events: user_module_events) }

  let(:now) { Time.zone.now }

  include_context 'with progress'

  describe '#started?' do
    let(:user_module_events) do
      [
        EventStub.new('module_start', { 'training_module_id' => 'alpha', 'id' => '1-1' }, now - 1.minute),
      ]
    end

    it 'is true once the module start event is recorded' do
      expect(progress.started?).to be true
    end
  end

  describe '#completed?' do
    let(:user_module_events) do
      [
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => 'what-to-expect' }, now - 6.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1' }, now - 5.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-1' }, now - 4.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-2' }, now - 3.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-3' }, now - 2.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-3-1' }, now - 1.minute),
        EventStub.new('module_complete', { 'training_module_id' => 'alpha', 'id' => 'thank_you' }, now),
      ]
    end

    it 'is true once every page is viewed (certificate excluded)' do
      expect(progress.completed?).to be true
    end
  end

  describe '#completed_at' do
    let(:user_module_events) do
      [
        EventStub.new('module_complete', { 'training_module_id' => 'alpha', 'id' => 'thank_you' },
                      Time.zone.local(2025, 1, 1)),
      ]
    end

    it 'uses module_complete time' do
      expect(progress.completed_at.to_s).to eq '2025-01-01 00:00:00 UTC'
    end
  end

  describe '#milestone' do
    let(:user_module_events) do
      [
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1' }, now - 3.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-2-1-1' }, now - 1.minute),
      ]
    end

    it 'is the name of the last viewed page' do
      expect(progress.milestone).to eq '1-2-1-1'
    end
  end

  describe '#resume_page' do
    let(:user_module_events) do
      [
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => 'what-to-expect' }, now - 6.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1' }, now - 5.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-1' }, now - 4.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-2' }, now - 3.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-3' }, now - 2.minutes),
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-3-1' }, now - 1.minute),
      ]
    end

    it 'is the most recently visited page' do
      expect(progress.resume_page.name).to eq '1-1-3-1'
    end

    context 'when another page is viewed later' do
      let(:user_module_events) do
        [
          EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1-3-1' }, now - 2.minutes),
          EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1' }, now - 1.minute),
        ]
      end

      it 'updates to the most recent page' do
        expect(progress.resume_page.name).to eq '1-1'
      end
    end
  end

  describe '#module_page_events' do
    let(:user_module_events) do
      [
        # Event with no time — should be treated as earliest (Time.at(0))
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '2-1' }, nil),

        # Event with an older timestamp
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '1-1' }, now - 5.minutes),

        # Event with the most recent timestamp
        EventStub.new('page_view', { 'training_module_id' => 'alpha', 'id' => '3-1' }, now - 1.minute),
      ]
    end

    it 'returns events sorted by time, with events missing time treated as earliest' do
      # The expected order is:
      # 1. Event with nil time ('2-1') - sorted to the front by Time.at(0)
      # 2. Event with older timestamp ('1-1')
      # 3. Event with most recent timestamp ('3-1')
      sorted_ids = progress.send(:module_page_events).map { |e| e.properties['id'] }
      expect(sorted_ids).to eq(%w[2-1 1-1 3-1])
    end
  end
end
