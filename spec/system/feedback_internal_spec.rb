require 'rails_helper'

RSpec.describe 'Feedback internal' do
  before do
    visit '/feedback'
  end

  describe 'foo' do
    it 'bar' do
      expect(page).to have_content 'The purpose of this feedback form is to gather your opinion on the child development training course'
    end
  end
end
