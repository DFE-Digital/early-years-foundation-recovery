require 'rails_helper'

RSpec.describe ApplicationForm do
  subject(:form) { described_class.new }

  describe '#parent title' do
    specify do
      expect(form.parent.title).to be_nil
    end
  end

  describe '#save' do
    specify do
      expect { form.save }.to raise_error ApplicationForm::FormError
    end
  end
end
