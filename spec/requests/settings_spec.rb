require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  specify { expect('/settings/cookie-policy').to be_successful }
end
