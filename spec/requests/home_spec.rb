require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  specify { expect('/').to be_successful }

  specify { expect('/health').to be_successful }

  it 'shows the number of live modules' do
    get root_path

    expected_summary = I18n.t(
      'home.modules_summary',
      count: Training::Module.live.count,
    )
    expect(response.body).to include(expected_summary)
  end
end
