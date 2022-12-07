require 'rails_helper'

describe 'TimeoutHelper', type: :helper do
  it 'timeout duration should match rails config' do
    expect(helper.timeout_duration).to match(Rails.configuration.user_timeout_minutes)
  end
end
