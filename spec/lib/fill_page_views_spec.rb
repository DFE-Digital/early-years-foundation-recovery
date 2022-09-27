require 'rails_helper'
require 'fill_page_views'

RSpec.describe FillPageViews do
  subject(:service) { described_class.new }

  include_context 'with progress'

  before do
    start_second_submodule(alpha)
  end

  context 'with skipped pages' do
    it 'no' do
      expect(Ahoy::Event.count).to be 10
      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - not skipped/).to_stdout_from_any_process
      expect(Ahoy::Event.count).to be 10
    end
  end

  context 'with no skipped pages' do
    it 'yes' do
      expect(Ahoy::Event.count).to be 10

      Ahoy::Event.where_properties(id: '1-1-1').first.delete
      Ahoy::Event.where_properties(id: '1-1-3').first.delete
      expect(Ahoy::Event.count).to be 8

      expect(Ahoy::Event.where_properties(id: '1-1-1').first).to be_nil
      expect(Ahoy::Event.where_properties(id: '1-1-3').first).to be_nil

      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - \[2\] skipped before page \[10\]/).to_stdout_from_any_process

      expect(Ahoy::Event.count).to be 10

      Ahoy::Event.where_properties(id: '1-1-1').first.properties['skipped']
      Ahoy::Event.where_properties(id: '1-1-3').first.properties['skipped']

      expect { service.call }.to output(/user \[\d+\] module \[\d+\] - not skipped/).to_stdout_from_any_process

      expect(Ahoy::Event.count).to be 10
    end
  end
end
