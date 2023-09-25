require 'rails_helper'

RSpec.describe Training::Page, type: :model do
  subject(:page) do
    # NB: query class is only possible with a page name that is unique
    described_class.find_by(name: '1-1-1-1').first
  end

  # describe 'CMS fields' do
  # end

  describe '#parent' do
    it 'returns the parent module' do
      expect(page.parent).to be_a Training::Module
      expect(page.parent.name).to eq 'charlie'
    end
  end

  describe '#schema' do
    it 'returns the schema' do
      expect(page.schema).to eq ['1-1-1-1', 'text_page', 'text_page', {}]
    end
  end
end
