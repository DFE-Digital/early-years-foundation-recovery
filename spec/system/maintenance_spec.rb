require 'rails_helper'

RSpec.describe 'Service unavailable' do
  shared_examples 'down for maintenance' do
    it 'makes the service unavailable' do
      expect(page).to have_title 'Early years child development training : Sorry, the service is unavailable'
      expect(page).to have_content 'Sorry, the service is unavailable'
    end
  end

  before do
    allow(Rails.application).to receive(:maintenance?).and_return(true)
    visit destination
  end

  context 'with internal health check' do
    let(:destination) { '/health' }

    specify { expect(destination).to be_successful }
  end

  context 'with maintenance page' do
    let(:destination) { '/maintenance' }

    specify { expect(destination).to be_successful }
  end

  context 'with a public page' do
    let(:destination) { '/' }

    specify { expect(destination).not_to be_successful }

    it_behaves_like 'down for maintenance'
  end

  context 'with a private page' do
    let(:destination) { '/my-account' }

    specify { expect(destination).not_to be_successful }

    it_behaves_like 'down for maintenance'
  end
end
