require 'rails_helper'

describe 'ApplicationHelper', type: :helper do
  it '#html_title' do
    expect(helper.html_title(:foo, 'bar')).to eq 'Early years child development training : foo : bar'
  end
end
