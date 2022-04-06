require 'rails_helper'

RSpec.describe Users::NameForm do
  let(:name_form) { described_class.new(user: create(:user)) }

  specify 'first name must be present' do
    name_form.first_name = ''
    name_form.validate
    expect(name_form.errors[:first_name].first).to eq('Enter a first name.')
  end

  specify 'surname must be present' do
    name_form.last_name = ''
    name_form.validate
    expect(name_form.errors[:last_name].first).to eq('Enter a surname.')
  end
end
