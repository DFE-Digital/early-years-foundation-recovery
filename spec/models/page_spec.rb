require 'rails_helper'

RSpec.describe Page, type: :model do
  describe '.by_name' do
    specify do
      expect(described_class.by_name('sitemap')).to be_a described_class
    end
  end

  describe '.footer' do
    specify do
      expect(described_class.footer.count).to be 4
    end
  end

  describe '#title' do
    specify do
      expect(described_class.by_name('sitemap').title).to eq 'Sitemap'
    end
  end
end
