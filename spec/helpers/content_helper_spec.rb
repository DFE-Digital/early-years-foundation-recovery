require 'rails_helper'

describe 'ContentHelper#translate_markdown', type: :helper do
  subject(:html) { helper.translate_markdown(input) }

  describe 'plain text' do
    let(:input) { 'text' }

    it 'returns text within p tags' do
      expect(html.strip).to eq '<p>text</p>'
    end
  end

  describe 'markdown' do
    let(:input) { '## text' }

    it 'translates markdown' do
      expect(html.strip).to eq '<h2 id="text">text</h2>'
    end
  end

  describe 'govspeak' do
    let(:input) { '%This is a warning callout%' }

    it 'uses Govspeak warning callout' do
      expect(html).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
      expect(html).to include '<p>This is a warning callout</p>'
    end
  end
end
