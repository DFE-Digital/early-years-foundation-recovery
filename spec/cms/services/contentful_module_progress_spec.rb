require 'rails_helper'

RSpec.describe ContentfulModuleProgress, :cms do
  subject(:progress) { described_class.new(user: user, mod: alpha) }

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  include_context 'with progress'

  describe '#started?' do
    it 'is true once the first submodule is viewed' do
      expect(progress.started?).to be false
      start_module(alpha)
      expect(progress.started?).to be true
    end
  end

  describe '#completed?' do
    it 'is true once every page is viewed (certificate excluded)' do
      expect(progress.completed?).to be false
      complete_module(alpha)
      expect(progress.completed?).to be true
    end
  end

  describe '#completed_at' do
    include_context 'with events'

    let(:completed_at) { progress.completed_at.to_s }

    before do
      create_event(user, 'module_complete', Time.zone.local(2025, 0o1, 0o1), 'alpha')
    end

    it 'uses module_complete time' do
      expect(completed_at).to eq '2025-01-01 00:00:00 UTC'
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
