require 'rails_helper'
require 'seed_snippets'

RSpec.describe SeedSnippets do
  subject(:service) { described_class.new }

  it do
    expect(service.call.first).to eql({ name: 'user.show.your_setting_details_html', body: "<h2 class='govuk-heading-m'>Your setting details</h2>" })
  end
end
