require 'rails_helper'

RSpec.describe "routes for training", type: :routing do
  specify { expect(get('/modules/alpha')).to route_to("training_modules#show")}
  specify { expect(get('/modules/delta')).to route_to("training_modules#show")}
end