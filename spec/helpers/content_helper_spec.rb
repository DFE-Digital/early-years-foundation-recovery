require 'rails_helper'

describe 'ContentHelper', type: :helper do
  describe '#service_name' do
    it { expect(helper.service_name).to eq 'Early years child development training' }
  end

  describe '#privacy_policy_url' do
    it { expect(helper.privacy_policy_url).to eq 'https://www.gov.uk/government/publications/privacy-information-members-of-the-public/privacy-information-members-of-the-public' }
  end

  describe '#completed_modules_table' do
    subject(:html) { helper.completed_modules_table }

    let(:user) { create(:user, :registered) }

    before do
      create :event,
             name: 'module_complete',
             user: user, properties:
             { training_module_id: 'alpha' }

      allow(helper).to receive(:current_user).and_return(user)
    end

    it 'creates a table' do
      expect(html).to include '<table class="govuk-table">'
      expect(html).to include 'Completed modules'
      expect(html).to include 'Module name'
      expect(html).to include 'Date completed'
      expect(html).to include 'Actions'
      expect(html).to have_link 'First Training Module', href: '/modules/alpha'
      expect(html).to have_link 'View certificate', href: '/modules/alpha/content-pages/1-3-4'
    end
  end

  describe '#m' do
    subject(:html) { helper.m(input) }

    context 'with a locale key' do
      subject(:html) do
        helper.m('about.course', all_modules: 10, published_modules: 2)
      end

      it 'interpolates variables' do
        expect(html).to include 'The course has 10 modules.'
        expect(html).to include '2 modules are currently available.'
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

    context 'with potentially malicious HTML' do
      let(:input) { "## Closing your account\n\n<script>alert('oops')</script>" }

      it 'sanitizes script tags to prevent XSS' do
        expect(html).not_to include '<script>'
        expect(html).not_to include '</script>'
        expect(html).to include '<h2 id="closing-your-account" class="govuk-heading-m">Closing your account</h2>'
        expect(html).to include "alert('oops')"
      end
    end

    context 'with malicious event handlers' do
      let(:input) { '<img src="x" onerror="alert(1)">' }

      it 'removes dangerous event handlers' do
        expect(html).not_to include 'onerror'
        expect(html).not_to include 'alert'
      end
    end

    context 'with inline javascript' do
      let(:input) { '<a href="javascript:alert(1)">Click me</a>' }

      it 'removes javascript: protocol' do
        expect(html).not_to include 'javascript:'
        expect(html).not_to include 'alert'
      end
    end

    context 'with malicious image src using javascript protocol' do
      let(:input) { '<img src="javascript:alert(\'xss\')" alt="test">' }

      it 'removes the javascript: protocol from img src' do
        expect(html).not_to include 'javascript:'
        expect(html).not_to include 'alert'
      end
    end

    context 'with malicious data URL in image' do
      let(:input) { '<img src="data:text/html,<script>alert(1)</script>" alt="test">' }

      it 'removes data: protocol URLs' do
        expect(html).not_to include 'data:'
        expect(html).not_to include '<script>'
      end
    end

    context 'with legitimate image' do
      let(:input) { '![test image](/path/to/image.jpg)' }

      it 'preserves legitimate images with relative URLs' do
        expect(html).to include '<img'
        expect(html).to include 'src="/path/to/image.jpg"'
        expect(html).to include 'alt="test image"'
      end
    end

    context 'with legitimate https image' do
      let(:input) { '<img src="https://example.com/image.jpg" alt="test">' }

      it 'preserves legitimate images with https protocol' do
        expect(html).to include '<img'
        expect(html).to include 'src="https://example.com/image.jpg"'
      end
    end

    context 'with protocol-relative URL from Contentful CDN' do
      let(:input) { '![](//images.ctfassets.net/test/test/test/_assets_0-0-0-0-0.jpg)' }

      it 'preserves protocol-relative URLs used by CDNs' do
        expect(html).to include '<img'
        expect(html).to include '//images.ctfassets.net'
      end
    end

    context 'with custom markup' do
      describe 'button' do
        let(:input) { '{button}[text](/link){/button}' }

        it 'creates a button link' do
          expect(html).to eq <<~HTML.strip
            <p class="govuk-body-m"><a href="/link" class="govuk-link govuk-button">
            text
            </a></p>
          HTML
        end
      end

      describe 'external' do
        let(:input) { '{external}[text](https://forms.external.com/foo.aspx?id=xxx){/external}' }

        it 'creates an external link' do
          expect(html).to eq <<~HTML.strip
            <p class="govuk-body-m"><a href="https://forms.external.com/foo.aspx?id=xxx" class="govuk-link" target="_blank" rel="noopener noreferrer">
            text (opens in a new tab)
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
          expect(html).to include '<div class="prompt">'
          expect(html).to include '<i aria-describedby="info icon" class="fa-2x fa-solid fa-info"></i>'
          expect(html).to include '<h2 class="govuk-heading-m">In your setting</h2>'
          expect(html).to include '<p class="govuk-body-m">hello world</p>'
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
          expect(html).to include '<div class="prompt prompt-bg">'
          expect(html).to include '<i aria-describedby="brain icon" class="fa-2x fa-solid fa-brain"></i>'
          expect(html).to include '<h2 class="govuk-heading-m">Reflection point</h2>'
          expect(html).to include '<p class="govuk-body-m">hello world</p>'
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
          expect(html).to include '<div class="prompt">'
          expect(html).to include '<i aria-describedby="book icon" class="fa-2x fa-solid fa-book"></i>'
          expect(html).to include '<h2 class="govuk-heading-m">Further reading</h2>'
          expect(html).to include '<p class="govuk-body-m">hello world</p>'
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
          expect(html).to include '<div class="blockquote-container">'
          expect(html).to include '<blockquote class="quote">'
          expect(html).to include '<p class="govuk-body-m">Life is trying things to see if they work.</p>'
          expect(html).to include '<cite>Ray Bradbury</cite>'
        end
      end

      describe 'Row templates' do
        let(:input) do
          <<~MARKUP
            {two_thirds}
            Description of an image

            ![image title](/path/to/image)
            {/two_thirds}
          MARKUP
        end

        it 'builds semantic markup' do
          expect(html).to include '<div class="govuk-grid-row">'
          expect(html).to include '<div class="govuk-grid-column-two-thirds">'
          expect(html).to include '<p class="govuk-body-m">Description of an image</p>'
          expect(html).to include '<div class="govuk-grid-column-one-third">'
          expect(html).to include '<img src="/path/to/image" alt="image title">'
        end
      end
    end
  end
end
