require 'rails_helper'

RSpec.describe Page::Resource, type: :model do
  describe '.by_name' do
    specify do
      expect(described_class.by_name('test.resource')).to be_a Page::Resource
    end
  end

  describe '.ordered' do
    specify do
      expect(described_class.ordered).to be_one
    end
  end
end
