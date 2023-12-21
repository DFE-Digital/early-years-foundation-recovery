require 'rails_helper'

RSpec.describe 'About' do
  before { visit(path) }

  describe 'the course' do
    let(:path) { course_overview_path }

    it { expect(page).to have_current_path '/about-training' }

    it 'has a hero section' do
      within '#hero-layout' do
        expect(page).to have_content 'About this training course'
        expect(page).to have_content 'The course has 4 modules. 3 modules are currently available.'
      end
    end
  end

  describe 'the experts' do
    let(:path) { experts_path }

    it { expect(page).to have_current_path '/about/the-experts' }

    it 'has a hero section' do
      within '#hero-layout' do
        expect(page).to have_content 'The experts'
        expect(page).to have_content 'This training course has been created by early years experts.'
      end
    end
  end

  describe 'the first module' do
    let(:path) { about_path(:alpha) }

    it { expect(page).to have_current_path '/about/alpha' }

    it 'has a hero section' do
      within '#hero-layout' do
        expect(page).to have_content 'First Training Module'
        expect(page).to have_content 'first module description'
      end
    end
  end
end
