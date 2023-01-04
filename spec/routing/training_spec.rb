require 'rails_helper'

RSpec.describe "routes for training", type: :routing do
  context "existing routing" do
    specify { expect(get('/modules/alpha')).to route_to(controller: "training_modules", action: "show", id: "alpha")}
    specify { expect(get('/modules/delta')).to route_to(controller: "training_modules", action: "show", id: "delta")}
  end
end