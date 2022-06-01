require 'rails_helper'

RSpec.describe 'Static page', type: :request do
  specify { expect('/terms_and_conditions').to be_successful }

  specify { expect('/accessibility_statement').to be_successful }

  specify { expect('/privacy_policy').to be_successful }

  specify { expect('/contact').to be_successful }

  specify { expect('/users/timeout').to be_successful }

  specify { expect('/404').to be_successful }

  specify { expect('/500').to be_successful }
end
