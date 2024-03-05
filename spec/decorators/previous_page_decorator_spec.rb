require 'rails_helper'

RSpec.describe PreviousPageDecorator do
  subject(:decorator) do
    described_class.new(user: user, mod: mod, content: content, assessment: assessment)
  end

  let(:user) { create :user, :registered }
  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name('1-1-2') }
  let(:assessment) { double }

  it '#name' do
    expect(decorator.name).to eq '1-1-1'
  end

  it '#text' do
    expect(decorator.text).to eq 'Previous'
  end

  context 'when starting a section' do
    let(:content) { mod.page_by_name('1-2') }

    it '#text' do
      expect(decorator.text).to eq 'Previous'
    end
  end

  context 'when finishing a module and skipping feedback form' do
    let(:content) { mod.page_by_name('1-3-3-5') }

    it '#text' do
      expect(decorator.text).to eq 'Previous'
    end

    it '#name' do
      expect(decorator.name).to eq 'feedback-intro'
    end
  end
end
