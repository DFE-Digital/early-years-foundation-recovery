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
      let(:current_visit) { create(:visit) }

      it 'uses the current visit' do
        allow(controller).to receive(:current_visit).and_return(current_visit)
        expect(guest.visit.id).to eq current_visit.id
        expect(guest).to be_a Guest
      end
    end

    context 'with a cookie' do
      let(:cookie_token) { 'some-token' }

      before do
        create(:visit, visit_token: cookie_token)
        request.cookies[:course_feedback] = cookie_token
      end

      it 'fetches a previous visit' do
        expect(guest).to be_a Guest
        expect(guest.visit_token).to eq cookie_token
      end
    end
  end
end
