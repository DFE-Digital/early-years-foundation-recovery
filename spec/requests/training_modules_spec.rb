require 'rails_helper'

RSpec.describe 'TrainingModules', type: :request do
  describe 'GET /about-training' do
    let(:published_modules) { TrainingModule.where(draft: nil) }

    before do
      sign_in create(:user, :registered)
      get course_overview_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    # it 'lists published training modules' do
    #   published_modules.each do |mod|
    #     expect(response.body).to include(mod.title)
    #     expect(response.body).to include(mod.description)
    #    expect(response.body).to include(mod.objective)
    #   end
    # end

    it 'omits draft modules' do
      expect(response.body).not_to include('delta')
    end
  end

  # describe 'GET /modules/alpha' do
  #   let(:training_module) { TrainingModule.first }

  #   before do
  #     sign_in create(:user, :registered)
  #     get training_module_path(training_module)
  #   end

  #   it 'returns http success' do
  #     expect(response).to have_http_status(:success)
  #   end

  #   it 'shows training module' do
  #     expect(response.body).to include(training_module.title)
  #     expect(response.body).to include(training_module.description)
  #   end
  # end
end
