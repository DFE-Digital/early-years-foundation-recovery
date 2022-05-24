require 'rails_helper'

RSpec.describe 'Static page', type: :request do
  specify { expect('/static/terms_and_conditions').to be_successful }

  specify { expect('/static/accessibility_statement').to be_successful }

  specify { expect('/static/privacy_policy').to be_successful }

  specify { expect('/users/timeout').to be_successful }

  specify { expect('/404').to be_successful }

  specify { expect('/500').to be_successful }
end
