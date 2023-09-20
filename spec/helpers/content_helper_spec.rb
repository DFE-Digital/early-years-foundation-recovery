require 'rails_helper'

describe 'ContentHelper', type: :helper do
  describe '#content_resource' do
    subject(:html) do
      helper.content_resource('email_advice.not_received', link: 'foo')
    end

    it 'wraps content in govspeak element' do
      expect(html).to include '<div class="gem-c-govspeak">'
    end

    it 'applies Kramdown styling' do
      expect(html).to include '<p class="govuk-heading-s">I haven’t received the email</p>'
    end

    it 'interpolates variables' do
      expect(html).to include '<a href="foo">Send me another email</a>'
    end
  end

  describe '#translate_markdown' do
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
      describe 'YouTube' do
        let(:input) { '$YT[Test title](foo)$ENDYT' }

        it 'embeds video' do
          expect(html).to include 'title="Test title"'
          expect(html).to include 'src="https://www.youtube.com/embed/foo?enablejsapi=1&amp;origin=recovery.app"'
        end
      end

      describe 'Vimeo' do
        let(:input) { '$VM[Test title](foo)$ENDVM' }

        it 'embeds video' do
          expect(html).to include 'title="Test title"'
          expect(html).to include 'src="https://player.vimeo.com/video/foo?enablejsapi=1&amp;origin=recovery.app"'
        end
      end

      describe 'In your setting prompt' do
        let(:input) do
          <<~INFO
            $INFO
            - one
            - two
            - three
            $INFO
          INFO
        end

        it 'uses the info icon' do
          expect(html).to include '<i aria-describedby="info icon" class="fa-2x fa-solid fa-info">'
          expect(html).to include '<h2 class="govuk-heading-m">In your setting</h2>'
          expect(html).to include '<li>one</li>'
        end
      end

      describe 'Reflection point prompt' do
        let(:input) do
          <<~BRAIN
            $BRAIN
            - one
            - two
            - three
            $BRAIN
          BRAIN
        end

        it 'uses the brain icon' do
          expect(html).to include '<i aria-describedby="brain icon" class="fa-2x fa-solid fa-brain">'
          expect(html).to include '<h2 class="govuk-heading-m">Reflection point</h2>'
          expect(html).to include '<li>one</li>'
        end
      end

      describe 'Further reading prompt' do
        let(:input) do
          <<~BOOK
            $BOOK
            - one
            - two
            - three
            $BOOK
          BOOK
        end

        it 'uses the book icon' do
          expect(html).to include '<i aria-describedby="book icon" class="fa-2x fa-solid fa-book">'
          expect(html).to include '<h2 class="govuk-heading-m">Further reading</h2>'
          expect(html).to include '<li>one</li>'
        end
      end

      describe 'Big quote prompt' do
        let(:input) do
          <<~QUOTE
            $QUOTE
            a bird in the hand is worth two in the bush

            anon
            $QUOTE
          QUOTE
        end

        it 'builds semantic markup' do
          expect(html).to eq <<~QUOTE
            <div class="blockquote-container"><blockquote class="quote">
            <p>a bird in the hand is worth two in the bush</p>

            <cite>anon</cite>
            </blockquote></div>
          QUOTE
        end
      end
    end
  end

  describe '#service_name' do
    it { expect(helper.service_name).to eq 'Early years child development training' }
  end
end
