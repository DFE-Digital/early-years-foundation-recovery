require 'rails_helper'

RSpec.describe 'Govspeak' do
  include_context 'with user'

  context 'with module intro' do
    let(:path) { '/modules/alpha/content-pages/intro' }

    it_behaves_like 'a Govspeak page'
  end

  context 'with youtube page' do
    let(:path) { '/modules/alpha/content-pages/1-2-1-2' }

    it_behaves_like 'a Govspeak page'
  end

  xcontext 'with formative question' do
    let(:path) { '/modules/alpha/questionnaires/1-2-1-1' }

    it_behaves_like 'a Govspeak page'
  end

  context 'with summative question' do
    let(:path) { '/modules/alpha/questionnaires/1-3-2-3' }

    it_behaves_like 'a Govspeak page'
  end

  context 'with confidence question' do
    let(:path) { '/modules/alpha/questionnaires/1-3-3-2' }

    it_behaves_like 'a Govspeak page'
  end
end
