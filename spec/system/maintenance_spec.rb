require 'rails_helper'

RSpec.shared_examples 'displays service unavailable page' do
  it 'displays the service unavailable message and title' do
    expect(page).to have_css('h1', text: 'Sorry, the service is unavailable')
    expect(page).to have_title('Early years child development training : Sorry, the service is unavailable')
  end
end

RSpec.describe 'Service Unavailable' do
  before do
    allow(Rails.application).to receive(:maintenance?).and_return(true)
  end

  context 'when the service is unavailable and user navigates to home' do
    before do
      visit '/'
    end

    it_behaves_like 'displays service unavailable page'
  end

  context 'when the service is unavailable and user navigates to my modules page' do
    before do
      visit my_modules_path
    end

    it_behaves_like 'displays service unavailable page'
  end

  context 'when the service is unavailable and user is already on the service unavailable page' do
    before do
      visit '/maintenance'
    end

    it_behaves_like 'displays service unavailable page'
  end
end
