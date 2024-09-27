require 'rails_helper'

RSpec.describe Training::Page, type: :model do
  subject(:page) do
    # NB: query class is only possible with a page name that is unique
    described_class.find_by(name: '1-1-1-1').first
  end

  it_behaves_like 'updated content', '1-1-3'

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

  describe '#debug_summary' do
    it 'summarises information' do
      expect(page.debug_summary).to eq(
        <<~SUMMARY,
          uid: 1lD5q4W5MfV2MkBqCGbMA6
          module uid: 2eghGRABMvuDKfpIZBjRAT
          module name: charlie
          published at: Management Key Missing
          page type: text_page

          ---
          previous: 1-1-1
          current: 1-1-1-1
          next: 1-1-1-2

          ---
          submodule: 1
          topic: 1

          ---
          position in module: 4th
          position in submodule: 3rd
          position in topic: 2nd

          ---
          pages in submodule: 4
          pages in topic: 4
        SUMMARY
      )
    end
  end
end
