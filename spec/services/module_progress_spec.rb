require 'rails_helper'

RSpec.describe ModuleProgress do
  subject(:progress) { described_class.new(user: user, mod: alpha) }

  let(:alpha) { TrainingModule.find_by(name: :alpha) }

  include_context 'with progress'

  describe '#started?' do
    it 'is true once the module intro is viewed' do
      expect { start_module(alpha) }.to change(progress, :started?)
    end
  end

  describe '#visited?' do
    it 'is true once a page is viewed' do
      expect { view_module_page_event('alpha', 'intro') }.to change { progress.visited?(alpha.intro_page) }
    end
  end

  describe '#completed?' do
    it 'is true once every page is viewed (certificate excluded)' do
      expect { view_pages_upto_thankyou(alpha) }.to change(progress, :completed?)
    end
  end

  describe '#certified?' do
    it 'is true once every page is viewed (certificate included)' do
      expect { view_pages_upto_certificate(alpha) }.to change(progress, :certified?)
    end
  end

  describe '#completed_at' do
    include_context 'with events'

    context 'when the named event is present' do
      before do
        create_event(user, 'module_complete', Time.zone.local(2025, 0o1, 0o1), 'alpha')
        create_event(user, 'module_content_page', Time.zone.local(2026, 12, 31), 'alpha', '1-3-3-4')
      end

      it 'uses module_complete time' do
        expect(progress.completed_at.to_s).to eq '2025-01-01 00:00:00 UTC'
      end
    end

    # Redundant once ER-543 ensures this event is always present
    xcontext 'when the named event is not present' do
      before do
        create_event(user, 'module_content_page', Time.zone.local(2026, 12, 31), 'alpha', '1-3-3-4')
      end

      it 'uses final page view time' do
        expect(progress.completed_at.to_s).to eq '2026-12-31 00:00:00 UTC'
      end
    end
  end

  describe '#milestone' do
    it 'returns the name of the last viewed page' do
      view_module_page_event('alpha', '1-1')
      view_module_page_event('alpha', '1-2-1-1')
      expect(progress.milestone).to eq '1-2-1-1'

      view_module_page_event('alpha', '1-1-3')
      expect(progress.milestone).to eq '1-1-3'
    end
  end

  describe '#resume_page' do
    it 'returns the furthest visited module item' do
      %w[
        what-to-expect
        before-you-start
        intro
        1-1
        1-1-1
        1-1-2
        1-1-3
        1-1-3-1
      ].map do |page|
        view_module_page_event('alpha', page)
      end

      expect(progress.resume_page.name).to eq '1-1-3-1'

      view_module_page_event('alpha', '1-1')
      expect(progress.resume_page.name).to eq '1-1-3-1'
    end
  end
end
