require 'rails_helper'

RSpec.describe 'User routes', type: :routing do
  it 'does not expose the review sign-in route' do
    expect(get: '/users/review').not_to be_routable
  end
end
