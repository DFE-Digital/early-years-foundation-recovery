require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#guest' do
    subject(:guest) { controller.send(:guest) }

    let(:cookie_token) { 'some-token' }

    it 'is nil without a current_visit' do
      expect(guest).to be_nil
    end

    it 'is a Guest with a current_visit' do
      allow(controller).to receive(:current_visit).and_return(create(:visit))
      expect(guest).to be_a Guest
    end

    it 'restores a previous visit from a cookie' do
      allow(controller).to receive(:current_visit).and_return(create(:visit))
      create(:visit, visit_token: cookie_token)
      request.cookies[:course_feedback] = cookie_token
      expect(guest).to be_a Guest
      expect(guest.visit_token).to eq cookie_token
    end
  end
end
