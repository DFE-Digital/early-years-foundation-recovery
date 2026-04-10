require 'rails_helper'

RSpec.describe Page::Resource, type: :model do
  let(:mock_contentful) { MockContentfulService.new }

  before do
    allow(Page::Resource).to receive(:by_name).and_return(mock_contentful.find('test.resource'))
    allow(Page::Resource).to receive(:ordered).and_return([mock_contentful.find('test.resource')])
  end

  describe '.by_name' do
    specify do
      expect(Page::Resource.by_name('test.resource')).to be_a OpenStruct
    end
  end

  describe '.ordered' do
    specify do
      expect(Page::Resource.ordered).to be_one
    end
  end
end
