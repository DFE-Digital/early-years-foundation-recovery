require 'rails_helper'

RSpec.describe Training::PagesController, type: :controller do
  before do
    sign_in create(:user, :registered)
  end

  describe '#pdf?' do
    let(:pdf) { controller.send(:pdf?) }

    it 'returns false when the format is not PDF' do
      get :show, params: { training_module_id: 'alpha', id: '1-3-4' }
      expect(pdf).to be false
    end

    it 'returns true when the format is PDF' do
      get :show, params: { training_module_id: 'alpha', id: '1-3-4', format: 'pdf' }
    rescue ActionView::MissingTemplate
      expect(pdf).to be true
    end
  end
end
