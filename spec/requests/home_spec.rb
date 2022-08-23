require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  specify { expect('/').to be_successful }

  specify { expect('/health').to be_successful }
end
