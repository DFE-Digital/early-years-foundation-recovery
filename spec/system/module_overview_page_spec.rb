require 'rails_helper'

RSpec.describe 'Module overview page' do
  include_context 'with progress'
  include_context 'with user'
  
  before do
    # probably should change to be done more programatically
    visit training_module_path('alpha')
  end

  context 'when a user visits the module overview page' do
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


  end

end