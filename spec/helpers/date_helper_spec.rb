require 'rails_helper'

describe 'DateHelper' do
  describe '#certificate_date' do
    let(:input) { Time.zone.local(2001, 2, 3, 4, 5, 6) }

    it 'returns date in format "Day(in numbers) Month(in words) Year(in numbers)" format' do
      expect(helper.certificate_date(input)).to eq '3 February 2001'
    end
  end
end
