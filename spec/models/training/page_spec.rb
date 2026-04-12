require 'rails_helper'

RSpec.describe Training::Page, type: :model do
  subject(:page) do
    # NB: query class is only possible with a page name that is unique
    described_class.find_by(name: '1-1-1-1').first
  end

  describe 'published content (stubbed preview)' do
    require 'support/contentful_stub_service'
    include_context 'when stub contentful for published tests'
    it_behaves_like 'updated content', '1-1-3' unless ENV['CONTENTFUL_PREVIEW'] == 'true' # only possible with stubbed preview
  end

  # describe 'CMS fields' do
  # end

  describe '#parent' do
    it 'returns the parent module' do
      expect(page.parent).to be_a Training::Module unless ENV['CONTENTFUL_PREVIEW'] == 'true' # only possible with stubbed preview
      expect(page.parent.name).to eq 'charlie' unless ENV['CONTENTFUL_PREVIEW'] == 'true' # only possible with stubbed preview
    end
  end

  describe '#schema' do
    it 'returns the schema' do
      expect(page.schema).to eq ['1-1-1-1', 'text_page', 'text_page', {}]
    end
  end
end
