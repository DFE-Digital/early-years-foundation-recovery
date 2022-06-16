require 'rails_helper'

RSpec.describe 'Static page', type: :request do
  specify { expect('/terms-and-conditions').to be_successful }

  specify { expect('/accessibility-statement').to be_successful }

  specify { expect('/privacy-policy').to be_successful }

  specify { expect('/contact').to be_successful }

  specify { expect('/users/timeout').to be_successful }

  specify { expect('/404').to be_successful }

  specify { expect('/500').to be_successful }
end
