require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#guest' do
    subject(:guest) { controller.send(:guest) }

    context 'with a bot' do
      it 'instantiates a new visit' do
        expect(guest.visit.id).to be_nil
        expect(guest).to be_a Guest
      end
    end

    context 'with a browser' do
      it 'uses the current visit' do
        allow(controller).to receive(:current_visit).and_return(create(:visit))
        expect(guest).to be_a Guest
      end
    end

    context 'with a cookie' do
      let(:cookie_token) { 'some-token' }

      it 'fetches a previous visit' do
        allow(controller).to receive(:current_visit).and_return(create(:visit))
        create(:visit, visit_token: cookie_token)
        request.cookies[:course_feedback] = cookie_token
        expect(guest).to be_a Guest
        expect(guest.visit_token).to eq cookie_token
      end
    end
  end
end
