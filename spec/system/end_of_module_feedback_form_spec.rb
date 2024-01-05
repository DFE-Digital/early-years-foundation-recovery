require 'rails_helper'

RSpec.describe 'End of module feedback form' do
  include_context 'with progress'
  include_context 'with user'

  let(:feedback_path) { '/modules/alpha/questionnaires/1-3-3-1' }

  before do
    start_end_of_module_feedback_form(alpha)
  end

  describe 'intro' do
    before do
      visit '/modules/alpha/questionnaires/1-3-3'
    end

    it 'uses generic content' do
      expect(page).to have_content('Heading')
        .and have_content('Body')
    end
  end

  context 'when on a feedback question page' do
    before do
      visit feedback_path
    end

    context 'and no answer is selected' do
      before do
        click_on 'Next'
      end

      it 'displays error message' do
        expect(page).to have_content 'Please select an answer'
      end
    end
  end
end
