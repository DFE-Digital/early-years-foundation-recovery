require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:mock_contentful) { MockContentfulService.new }

  before do
    allow(Page).to receive(:by_name).and_return(mock_contentful.find('sitemap'))
    allow(Page).to receive(:footer).and_return([mock_contentful.find('footer1'), mock_contentful.find('footer2'), mock_contentful.find('footer3'), mock_contentful.find('footer4')])
  end

  describe '.by_name' do
    specify do
      expect(Page.by_name('sitemap')).to be_a OpenStruct
    end
  end

  describe '.footer' do
    specify do
      expect(Page.footer.count).to be 4
    end
  end

  describe '#title' do
    specify do
      expect(Page.by_name('sitemap').title).to eq 'Mock Title'
    end
  end
end
