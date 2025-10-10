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
          expect(html).to eq '<div class="govuk-grid-row"><div class="govuk-grid-column-two-thirds"><p class="govuk-body-m">Description of an image</p></div><div class="govuk-grid-column-one-third"><p class="govuk-body-m"><img src="/path/to/image" alt="image title"></p></div></div>'
        end
      end

      describe 'Headings for h2 and h3' do
        let(:input) do
          <<~MARKUP
            ## My sub
            ### My sub 2
          MARKUP
        end

        it 'renders heading using correct heading class' do
          expect(html).to eq <<~HTML.strip
            <h2 id="my-sub" class="govuk-heading-m">My sub</h2>
            <h3 id="my-sub-2" class="govuk-heading-s">My sub 2</h3>
          HTML
        end
      end

      describe 'Headings for h3 then h2' do
        let(:input) do
          <<~MARKUP
            ### My h3 heading
            ## My h2 heading
          MARKUP
        end

        it 'renders heading using correct heading class' do
          expect(html).to eq <<~HTML.strip
            <h3 id="my-h3-heading" class="govuk-heading-s">My h3 heading</h3>
            <h2 id="my-h2-heading" class="govuk-heading-m">My h2 heading</h2>
          HTML
        end
      end
    end
  end
end
