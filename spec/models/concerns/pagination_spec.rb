require 'rails_helper'

RSpec.describe Pagination do
  subject(:page) { mod.page_by_name('1-1-4-1') }

  let(:mod) { Training::Module.by_name(:alpha) }

  describe '#submodule' do
    specify { expect(page.submodule).to eq(1) }
  end

  describe '#topic' do
    specify { expect(page.topic).to eq(4) }
  end

  describe '#position_within' do
    it 'returns the oridinal' do
      expect(page.position_within(page.parent.pages)).to eq '8th'
      expect(page.position_within(page.section_content)).to eq '7th'
      expect(page.position_within(page.subsection_content)).to eq '2nd'
    end
  end

  describe '#section?' do
    it 'returns true if the page defines a section boundary' do
      expect(page.section?).to eq(false)
      expect(mod.page_by_name('1-2').section?).to eq(true)
    end
  end

  describe '#subsection?' do
    it 'returns true if the page defines a subsection boundary' do
      expect(page.subsection?).to eq(false)
      expect(mod.page_by_name('1-3-2').subsection?).to eq(true) # assessment subsection
    end
  end
end
