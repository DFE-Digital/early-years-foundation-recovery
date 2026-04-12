require 'rails_helper'

RSpec.describe Page, type: :model do
  describe '.by_name' do
    it 'returns a Page instance for a valid name' do
      page = described_class.by_name('sitemap')
      expect(page).to be_a described_class
    end
  end

  describe '.footer' do
    it 'returns the expected number of footer pages' do
      expect(described_class.footer.count).to eq 4
    end
  end

  describe '#title' do
    it 'returns the correct title for the sitemap page' do
      page = described_class.by_name('sitemap')
      expect(page.title).to eq 'Sitemap'
    end
  end
end
