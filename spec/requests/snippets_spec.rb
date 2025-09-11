require 'rails_helper'

RSpec.describe 'Snippets', type: :request do
  before do
    get snippet_path(resource)
  end

  context 'when authored' do
    let(:resource) { 'about.summary' }

    it 'is expected to include microcopy' do
      # NB: variables are not processed
      expect(response.body).to include '%{outcomes}'
    end

    specify { expect(response).to have_http_status(:success) }
  end

  context 'when not authored' do
    let(:resource) { 'unwritten.content.name' }

    specify do
      expect(response.body).to include '<p class="govuk-body">unwritten.content.name</p>'
    end

    specify { expect(response).to have_http_status(:success) }
  end
end
