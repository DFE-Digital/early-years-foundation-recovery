require 'rails_helper'

RSpec.describe 'Module overview page progress' do
  include_context 'with progress'
  include_context 'with user'

  context 'when the module has not been started' do
    before do
      visit '/modules/alpha'
    end

    it 'all the indicators are "not started"' do
      within '#section-content-1' do
        expect(page).to have_content 'not started', count: 4
        expect(page).to have_content('1-1-1')
        expect(page).not_to have_link('1-1-1')
      end

      within '#section-content-2' do
        expect(page).to have_content 'not started', count: 1
      end

      within '#section-content-3' do
        expect(page).to have_content 'not started', count: 3
        expect(page).not_to have_link 'Recap'
        expect(page).not_to have_link 'End of module test'
        expect(page).not_to have_link 'Reflect on your learning'
      end

      within '#section-content-4' do
        expect(page).to have_content 'not started', count: 1
        expect(page).not_to have_link 'Download your certificate'
      end
    end

    it 'resumes from the interruption page' do
      expect(page).to have_link 'Start', href: '/modules/alpha/content-pages/what-to-expect'
    end

    it 'shows the end of module test has not been attempted' do
      within '#section-content-3' do
        expect(page).not_to have_content('in progress')
        expect(page).not_to have_content('completed')
      end
    end

    it 'shows the module recap is not clickable' do
      expect(page).not_to have_link('Reflect on your learning', href: '/modules/alpha/content-pages/1-3-3')
    end
  end

  context 'when the module intro is reached' do
    before do
      start_module(alpha)
      visit '/modules/alpha/content-pages/1-1'
      visit '/modules/alpha'
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link('Resume module', href: '/modules/alpha/content-pages/1-1')
    end
  end

  context 'when the first submodule intro is reached' do
    before do
      start_module(alpha)
      visit '/modules/alpha/content-pages/1-1'
      visit '/modules/alpha'
    end

    it 'the submodule indicator is "not started"' do
      within '#section-content-1' do
        expect(page).to have_content 'not started'
      end
    end

    it 'the first topic cannot be clicked' do
      within '#section-content-1 .module-section--container .module-section--item:nth-child(1)' do
        expect(page).not_to have_link('1-1-1', href: '/modules/alpha/content-pages/1-1-1')
      end
    end

    it 'the first topic indicator is "not started"' do
      within '#section-content-1 .module-section--container .progress-indicator:nth-child(2)' do
        expect(page).to have_content 'not started'
      end
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link('Resume module', href: '/modules/alpha/content-pages/1-1')
    end
  end

  context 'when the first topic is complete' do
    before do
      start_first_topic(alpha)
      visit '/modules/alpha'
    end

    it 'the first topic can be clicked' do
      within '#section-content-1 .module-section--container .module-section--item:nth-child(1)' do
        expect(page).to have_link('1-1-1', href: '/modules/alpha/content-pages/1-1-1')
      end
    end

    it 'the first topic indicator is "complete"' do
      within '#section-content-1 .module-section--container .progress-indicator:nth-child(2)' do
        expect(page).to have_content 'complete'
      end
    end

    it 'the second topic cannot be clicked' do
      within '#section-content-1 .module-section--container .module-section--item:nth-child(3)' do
        expect(page).not_to have_link('1-1-1', href: '/modules/alpha/content-pages/1-1-1')
      end
    end

    it 'the second topic indicator is "not started"' do
      within '#section-content-1 .module-section--container .progress-indicator:nth-child(4)' do
        expect(page).to have_content 'not started'
      end
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link 'Resume module', href: '/modules/alpha/content-pages/1-1-1'
    end
  end

  context 'when only some of a topic has been viewed' do
    before do
      view_pages_upto(alpha, 'topic_intro', 3)
      visit '/modules/alpha'
    end

    it 'the progress indicator is "in progress"' do
      within '#section-content-1 .module-section--container .progress-indicator:nth-child(6)' do
        expect(page).to have_content 'in progress'
      end
    end

    it 'the topic is not a link' do
      within '#section-content-1 .module-section--container .module-section--item:nth-child(5)' do
        expect(page).not_to have_link('1-1-3', href: '/modules/alpha/content-pages/1-1-3')
      end
    end
  end

  context 'when the last page of the first submodule is reached' do
    before do
      view_pages_upto alpha, 'formative'
      visit '/modules/alpha'
    end

    it 'all the indicators in the submodule are "complete"' do
      within '#section-content-1' do
        expect(page).to have_content 'complete', count: 4
      end
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link 'Resume module', href: '/modules/alpha/content-pages/1-1-4-1'
    end
  end

  context 'when the summative assessment is failed' do
    include_context 'with automated path'

    let(:happy) { false }

    before { visit '/modules/alpha' }

    specify { expect(page).to have_link 'Retake test' }
  end

  context 'when the whole module is complete' do
    before do
      complete_module(alpha)
      visit '/modules/alpha'
    end

    specify { expect(page).not_to have_link 'Retake test' }
  end

  context 'with just a completion event' do
    before do
      module_complete_event(alpha)
      visit '/modules/alpha'
    end

    it 'all the indicators are "complete"' do
      within '#section-content-1' do
        expect(page).to have_content 'complete', count: 4
      end

      within '#section-content-2' do
        expect(page).to have_content 'complete', count: 1
      end

      within '#section-content-3' do
        expect(page).to have_content 'complete', count: 3
      end

      within '#section-content-4' do
        expect(page).to have_content 'complete', count: 1
      end
    end
  end

  context 'when controller logic for progress decorator is applied' do
    before do
      visit '/modules/alpha'
    end

    it 'displays the correct number of decorated progress indicators' do
      expect(page).to have_selector('.progress-indicator', minimum: 9) # Adjust this if needed
    end

    it 'shows "not started" progress pulled from decorator logic' do
      within '#section-content-1' do
        expect(page).to have_content 'not started'
      end
    end
  end

  context 'when user progress influences visible content' do
    before do
      view_pages_upto alpha, 'topic_intro', 3
      visit '/modules/alpha'
    end

    it 'shows "in progress" state, proving controller calculated progress' do
      within '#section-content-1' do
        expect(page).to have_content 'in progress'
      end
    end

    it 'shows correct Resume link from progress' do
      expect(page).to have_link 'Resume module', href: '/modules/alpha/content-pages/1-1-3'
    end
  end
end
