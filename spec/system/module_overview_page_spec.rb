require 'rails_helper'

RSpec.describe 'When a user visits the module overview page' do
  include_context 'with progress'
  include_context 'with user'
  
  before do
    visit '/modules/alpha'
  end

  it 'can see the module name' do
    expect(page).to have_content('First Training Module')
  end

  it 'can see the module description' do
    expect(page).to have_content('first module description')
  end

  it 'can see a call to action button to start the module' do
    expect(page).to have_link('Start')
  end

  it 'can see the number of topics available in the module' do
    expect(page).to have_content('8 topics')
  end

  it 'can see the time taken to complete the module' do
    expect(page).to have_content('3 hours')
  end

  it 'can see the submodule names' do
    expect(page).to have_content('The first submodule')
    expect(page).to have_content('The second submodule')
    expect(page).to have_content('Summary and next steps')
  end

  it 'can see the topic names' do
    expect(page).to have_content('1-1-1')
      .and have_content('1-1-2')
      .and have_content('1-1-3')
      .and have_content('1-1-4')
      .and have_content('1-2-1')
      .and have_content('Recap')
      .and have_content('End of module test')
      .and have_content('Reflect on your learning')
  end

  it 'can see message telling user to complete previous submodule' do
    expect(page).to have_content('The first submodule must be completed before you begin this section')
      .and have_content('The second submodule must be completed before you begin this section')
  end
  
  context 'when the user has not begun the module' do
    it 'submodule tag says that the module has not been started yet' do
      within '#section-button-1' do
        expect(page).to have_content('not started')
      end
    end

    it 'first topic text is visible but is not a link' do
      within '#section-content-1' do
        expect(page).to have_content('1-1-1')
          .and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end
    end
  end
  
  context 'when the user has viewed the interruption page and module intro' do
    before do
      start_module(alpha)
      visit '/modules/alpha'
    end

    it 'submodule tag says that the module has not been started yet' do
      within '#section-button-1' do
        expect(page).to have_content('not started')
      end
    end

    it 'first topic text is visible but is not a link' do
      within '#section-content-1' do
        expect(page).to have_content('1-1-1')
          .and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end
    end

    it 'can click on the call to action button to continue the module' do
      click_link('Resume training')

      expect(page).to have_current_path('/modules/alpha/content-pages/intro')
    end
  end

  context 'when the user has started the first submodule' do
    before do
      start_submodule(alpha)
      visit '/modules/alpha'
    end

    it 'submodule tag says that the module has been started' do
      within '#section-button-1' do
        expect(page).to have_content('in progress')
      end
    end

    it 'can click on first topic link from the module overview page' do
      within '#section-content-1' do
        click_link('1-1-1')

        expect(page).to have_current_path('/modules/alpha/content-pages/1-1-1')
      end
    end

    it 'can click on the call to action button to continue the module' do
      click_link('Resume training')

      expect(page).to have_current_path('/modules/alpha/content-pages/1-1')
    end
  end
end
