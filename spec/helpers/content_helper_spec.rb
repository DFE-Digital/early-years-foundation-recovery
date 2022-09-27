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

  describe 'default govspeak' do
    let(:input) { '%This is a warning callout%' }

    it 'uses Govspeak warning callout' do
      expect(html).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
      expect(html).to include '<p>This is a warning callout</p>'
    end
  end

  describe 'custom govspeak' do
    describe '$YT' do
      let(:input) { '$YT[Test title](foo)$ENDYT' }

      it 'embeds YouTube content' do
        expect(html).to include 'title="Test title"'
        expect(html).to include 'src="https://www.youtube.com/embed/foo?enablejsapi=1&amp;origin=https%3A%2F%2Frecovery.app"'
      end
    end

    describe '$INFO' do
      let(:input) do
        <<~BANG
          $INFO
          - one
          - two
          - three
          $INFO
        BANG
      end

      it 'renders a tip' do
        expect(html).to include '<h2 class="govuk-heading-m">In your setting</h2>'
        expect(html).to include '<li>one</li>'
      end
    end
  end
end
