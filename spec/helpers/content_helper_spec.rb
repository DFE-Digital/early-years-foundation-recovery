require 'rails_helper'

describe 'ContentHelper', type: :helper do
  describe '#m' do
    subject(:html) { helper.m(input) }

    context 'with a locale key' do
      subject(:html) do
        helper.m('email_advice.not_received', link: 'foo')
      end

      it 'interpolates variables' do
        expect(html).to include '<a href="foo" class="govuk-link">Send me another email</a>'
      end
    end

    context 'with plain text' do
      let(:input) { 'text' }

      it 'returns text within p tags' do
        expect(html).to eq '<p class="govuk-body-m">text</p>'
      end
    end

    context 'with markdown' do
      let(:input) { '## text' }

      it 'translates markdown' do
        expect(html).to eq '<h2 id="text" class="govuk-heading-m">text</h2>'
      end
    end

    context 'with custom markup' do
      describe 'button' do
        let(:input) { '{button}[text](/link){/button}' }

        it 'creates a button link' do
          expect(html).to eq <<~HTML.strip
            <p class="govuk-body-m"><a href=/link class="govuk-link govuk-button">
            text
            </a></p>
          HTML
        end
      end

      describe 'external' do
        let(:input) { '{external}[text](/link){/external}' }

        it 'creates an external link' do
          expect(html).to eq <<~HTML.strip
            <p class="govuk-body-m"><a href=/link class="govuk-link" target="_blank" rel="noopener noreferrer">
            text (opens in new tab)
            </a></p>
          HTML
        end
      end

      describe 'In your setting prompt' do
        let(:input) do
          <<~MARKUP
            {info}
            hello world
            {/info}
          MARKUP
        end

        it 'uses the info icon' do
          expect(html).to eq '<div class="prompt"><div class="govuk-grid-row"><div class="govuk-grid-column-one-quarter"><i aria-describedby="info icon" class="fa-2x fa-solid fa-info"></i></div><div class="govuk-grid-column-three-quarters"><h2 class="govuk-heading-m">In your setting</h2><p class="govuk-body-m">hello world</p></div></div></div>'
        end
      end

      describe 'Reflection point prompt' do
        let(:input) do
          <<~MARKUP
            {brain}
            hello world
            {/brain}
          MARKUP
        end

        it 'uses the brain icon' do
          expect(html).to eq '<div class="prompt prompt-bg"><div class="govuk-grid-row"><div class="govuk-grid-column-one-quarter"><i aria-describedby="brain icon" class="fa-2x fa-solid fa-brain"></i></div><div class="govuk-grid-column-three-quarters"><h2 class="govuk-heading-m">Reflection point</h2><p class="govuk-body-m">hello world</p></div></div></div>'
        end
      end

      describe 'Further reading prompt' do
        let(:input) do
          <<~MARKUP
            {book}
            hello world
            {/book}
          MARKUP
        end

        it 'uses the book icon' do
          expect(html).to eq '<div class="prompt"><div class="govuk-grid-row"><div class="govuk-grid-column-one-quarter"><i aria-describedby="book icon" class="fa-2x fa-solid fa-book"></i></div><div class="govuk-grid-column-three-quarters"><h2 class="govuk-heading-m">Further reading</h2><p class="govuk-body-m">hello world</p></div></div></div>'
        end
      end

      describe 'Big quote prompt' do
        let(:input) do
          <<~MARKUP
            {quote}
            Life is trying things to see if they work.

            Ray Bradbury
            {/quote}
          MARKUP
        end

        it 'builds semantic markup' do
          expect(html).to eq '<div class="blockquote-container"><blockquote class="quote"><p class="govuk-body-m">Life is trying things to see if they work.</p><cite>Ray Bradbury</cite></blockquote></div>'
        end
      end
    end
  end

  describe '#service_name' do
    it { expect(helper.service_name).to eq 'Early years child development training' }
  end
end
