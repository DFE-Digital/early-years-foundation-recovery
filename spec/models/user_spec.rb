require 'rails_helper'
require 'webmock/rspec'

RSpec.describe User, type: :model do
  describe '#ofsted_number' do
    let(:source) { 'https://reports.ofsted.gov.uk/childcare/search' }

    it 'must be a valid' do
      # empty response
      stub_request(:get, "#{source}?q=").to_return(body: '')
      expect(build(:user, ofsted_number: nil)).not_to be_valid

      # not found
      stub_request(:get, "#{source}?q=foo").to_return(body: 'bar')
      expect(build(:user, ofsted_number: 'foo')).not_to be_valid

      # found
      stub_request(:get, "#{source}?q=EY551855").to_return(body: 'EY551855')
      expect(build(:user, ofsted_number: 'EY551855')).to be_valid
    end
  end
end
