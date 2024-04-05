require 'rails_helper'

describe 'Site wide feedback' do
  context 'when user is not logged in' do
    include_context 'with automated path'
    let(:fixture) { 'spec/support/ast/site-feedback-form-response-guest.yml' }

    it 'feedback can be completed' do
      expect(page).to have_title('Early years child development training : Home page')
    end
  end

  context 'with authenticated user' do
    include_context 'with user'
    include_context 'with automated path'

    context 'when user has not completed feedback' do

      let(:fixture) { 'spec/support/ast/site-feedback-form-response-user.yml' }

      it 'feedback can be completed' do
        expect(page).to have_content('My modules')
      end
    end

    context 'when user has completed feedback' do

      let(:fixture) { 'spec/support/ast/site-feedback-form-response-user-update.yml' }

      it 'feedback can be updated' do
        expect(page).to have_content('My modules')
      end
    end
  end
end
