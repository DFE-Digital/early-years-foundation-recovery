require 'rails_helper'

RSpec.describe 'Module overview' do
  include_context 'with progress'
  include_context 'with user'

  before do
    visit '/modules/alpha'
  end

  it 'has back button' do
    expect(page).to have_link('Back to My modules', href: '/my-modules')
  end

  it 'has the module number and name' do
    expect(page).to have_content('Module 1: First Training Module')
  end

  it 'has the module description' do
    expect(page).to have_content('first module description')
  end

  it 'has a call to action button to start the module' do
    expect(page).to have_link('Start module')
  end

  it 'has the intro name and pages' do
    expect(page).to have_content('Module introduction')
    expect(page).to have_content('What to expect during the training')
    expect(page).to have_content('Before you start')
    expect(page).to have_content('Govspeak Reference Page')
  end

  it 'has the submodule names' do
    expect(page).to have_content('The first submodule')
    expect(page).to have_content('The second submodule')
    expect(page).to have_content('Summary and next steps')
  end

  it 'has the topic names' do
    expect(page).to have_content('1-1-1')
      .and have_content('1-1-2')
      .and have_content('1-1-3')
      .and have_content('1-1-4')
      .and have_content('1-2-1')
      .and have_content('Recap')
      .and have_content('End of module test')
      .and have_content('Reflect on your learning')
  end
end
