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

  # used in debug summary
  describe '#position_within' do
    it 'returns the oridinal' do
      expect(page.position_within(page.parent.pages)).to eq '8th'
      expect(page.position_within(page.section_content)).to eq '7th'
      expect(page.position_within(page.subsection_content)).to eq '2nd'
    end
  end

  describe '#section?' do
    it 'returns true if the page defines a section boundary' do
      expect(page).not_to be_section
      expect(mod.page_by_name('1-2')).to be_section
    end
  end

  describe '#subsection?' do
    it 'returns true if the page defines a subsection boundary' do
      expect(page).not_to be_subsection
      expect(mod.page_by_name('1-3-2')).to be_subsection # assessment subsection
    end
  end

  context '#with_parent' do
    subject(:page) { mod.page_by_name('feedback-checkbox-other-or') }

    let(:mod) { Training::Module.by_name(:bravo) }

    it 'navigates shared content in the correct parent' do
      expect(page.parent.name).to eq 'alpha'
      expect(page.with_parent(mod).parent.name).to eq 'bravo'
      expect(page.with_parent(mod).next_item.parent.name).to eq 'alpha'

      expect(page.next_item.name).to eq 'feedback-skippable'
      expect(page.with_parent(mod).next_item.name).to eq 'feedback-skippable'
      expect(page.with_parent(mod).next_next_item.name).to eq '1-3-3-5-bravo'
    end
  end
end
