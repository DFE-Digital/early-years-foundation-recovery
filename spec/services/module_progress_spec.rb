# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModuleProgress do
  subject(:progress) { described_class.new(user: user, mod: alpha) }

  let(:now) { Time.zone.now }

  include_context 'with progress'

  describe '#started?' do
    context 'with UserModuleProgress record' do
      before do
        UserModuleProgress.create!(user: user, module_name: 'alpha', started_at: now - 1.minute)
      end

      it 'is true once the module is started' do
        expect(progress.started?).to be true
      end
    end

    context 'with no progress record' do
      it 'is false' do
        expect(progress.started?).to be false
      end
    end
  end

  describe '#completed?' do
    before do
      UserModuleProgress.create!(
        user: user,
        module_name: 'alpha',
        started_at: now - 10.minutes,
        completed_at: now,
      )
    end

    it 'is true once the module is completed' do
      expect(progress.completed?).to be true
    end
  end

  describe '#completed_at' do
    let(:completion_time) { Time.zone.local(2025, 1, 1) }

    before do
      UserModuleProgress.create!(
        user: user,
        module_name: 'alpha',
        started_at: completion_time - 1.hour,
        completed_at: completion_time,
      )
    end

    it 'uses the completed_at time from UserModuleProgress' do
      expect(progress.completed_at.to_s).to eq '2025-01-01 00:00:00 UTC'
    end
  end

  describe '#milestone' do
    before do
      UserModuleProgress.create!(
        user: user,
        module_name: 'alpha',
        started_at: now - 5.minutes,
        last_page: '1-1-3-1',
        visited_pages: {
          'what-to-expect' => (now - 5.minutes).iso8601,
          '1-1' => (now - 4.minutes).iso8601,
          '1-1-3-1' => (now - 1.minute).iso8601,
        },
      )
    end

    it 'is the name of the last viewed page' do
      expect(progress.milestone).to eq '1-1-3-1'
    end
  end

  describe '#resume_page' do
    before do
      UserModuleProgress.create!(
        user: user,
        module_name: 'alpha',
        started_at: now - 5.minutes,
        last_page: '1-1-3-1',
        visited_pages: {
          'what-to-expect' => (now - 5.minutes).iso8601,
          '1-1' => (now - 4.minutes).iso8601,
          '1-1-3-1' => (now - 1.minute).iso8601,
        },
      )
    end

    it 'is the most recently visited page' do
      expect(progress.resume_page.name).to eq '1-1-3-1'
    end
  end

  describe '#visited?' do
    before do
      UserModuleProgress.create!(
        user: user,
        module_name: 'alpha',
        started_at: now - 5.minutes,
        visited_pages: {
          'what-to-expect' => (now - 5.minutes).iso8601,
          '1-1' => (now - 4.minutes).iso8601,
        },
      )
    end

    it 'returns true for visited pages' do
      page = alpha.page_by_name('what-to-expect')
      expect(progress.visited?(page)).to be true
    end

    it 'returns false for unvisited pages' do
      page = alpha.page_by_name('1-1-1')
      expect(progress.visited?(page)).to be false
    end
  end

  describe '#value' do
    context 'with no pages visited' do
      it 'returns 0' do
        expect(progress.value).to eq 0.0
      end
    end

    context 'with some pages visited' do
      before do
        # Visit half the pages
        visited = {}
        alpha.content.first(alpha.content.size / 2).each do |page|
          visited[page.name] = now.iso8601
        end

        UserModuleProgress.create!(
          user: user,
          module_name: 'alpha',
          started_at: now - 5.minutes,
          visited_pages: visited,
        )
      end

      it 'returns the fraction of pages visited' do
        expect(progress.value).to be_within(0.1).of(0.5)
      end
    end
  end
end
