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
end
