require 'rails_helper'

RSpec.describe PaginationDecorator do
  subject(:decorator) do
    described_class.new(content)
  end

  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name('1-1-1') }

  it '#heading' do
    expect(decorator.heading).to eq 'The first submodule'
  end

  it '#section_numbers' do
    expect(decorator.section_numbers).to eq 'Section 1 of 4'
  end

  it '#page_numbers' do
    expect(decorator.page_numbers).to eq 'Page 2 of 7'
  end

  it '#percentage' do
    expect(decorator.percentage).to eq '29%'
  end
end
