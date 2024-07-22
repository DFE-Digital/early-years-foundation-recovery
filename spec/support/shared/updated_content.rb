RSpec.shared_examples 'updated content' do |name|
  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name(name) }

  describe '#edited?' do
    context 'when preview' do
      # make Rails.application.preview? return true
      it do
        allow(Rails.application).to receive(:preview?).and_return(true)
        expect(content.edited?).to be true
      end
    end

    context 'when delivery' do
      it do
        create(:module_release, first_published_at: Time.zone.local(2023, 1, 1))
        expect(content.edited?).to be true
      end

      it do
        create(:module_release, first_published_at: Time.zone.local(3_099, 1, 1))
        expect(content.edited?).to be false
      end
    end
  end

  describe '#published_at' do
    context 'when unpublished' do
      it do
        expect(content.published_at).to be_nil
      end
    end

    context 'when published' do
      before do
        create(:module_release, first_published_at: Time.zone.local(2023, 1, 1))
      end

      it do
        expect(content.published_at.to_s).to eq '2023-01-01 00:00:00 UTC'
      end
    end
  end
end
