require 'rails_helper'
require 'fill_page_views'

RSpec.describe FillPageViews do
  subject(:service) { described_class.new }

  before do
    skip 'CMS conversion WIP'
    ENV['VERBOSE'] = 'y'
  end

  after do
    ENV['VERBOSE'] = nil
  end

  include_context 'with progress'

  context 'without skipped pages' do
    before do
      start_module(alpha)
    end

    it 'has no effect' do
      expect(Event.count).to be 4
      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - not skipped/).to_stdout_from_any_process
      expect(Event.count).to be 4
    end
  end

  context 'with noncontiguous skipped pages' do
    before do
      start_second_submodule(alpha)
    end

    let(:pages) { %w[1-1-1 1-1-3] }

    it 'records "skipped" page views' do
      expect(Event.count).to be 9

      pages.each do |page|
        Event.where_properties(id: page).first.delete
      end

      expect(Event.count).to be 7

      pages.each do |page|
        event = Event.where_properties(id: page).first
        expect(event).to be_nil
      end

      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - \[2\] skipped before page \[1-2\]/).to_stdout_from_any_process

      expect(Event.count).to be 9

      pages.each do |page|
        event = Event.where_properties(id: page).first
        expect(event.properties['skipped']).to be true
      end

      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - not skipped/).to_stdout_from_any_process

      expect(Event.count).to be 9
    end
  end

  context 'with contiguous skipped pages' do
    before do
      complete_module(alpha)
    end

    let(:pages) { %w[1-2 1-2-1 1-2-1-1 1-2-1-2 1-2-1-3] }

    it 'records "skipped" page views' do
      expect(Event.where(name: 'module_start').count).to be 1
      expect(Event.where(name: 'module_content_page').count).to be 26
      expect(Event.where(name: 'module_complete').count).to be 1

      pages.each do |page|
        Event.where_properties(id: page).first.delete
      end

      expect(Event.count).to be 23

      pages.each do |page|
        event = Event.where_properties(id: page).first
        expect(event).to be_nil
      end

      # certificate page
      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - \[5\] skipped before page \[1-3-4\]/).to_stdout_from_any_process

      expect(Event.count).to be 28

      pages.each do |page|
        event = Event.where_properties(id: page).first
        expect(event.properties['skipped']).to be true
      end

      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - not skipped/).to_stdout_from_any_process

      expect(Event.count).to be 28
    end
  end
end
