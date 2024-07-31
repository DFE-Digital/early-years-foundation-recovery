RSpec.shared_examples 'updated content' do |name|
  before do
    create(:module_release, first_published_at: Time.zone.local(2023, 1, 1))
  end

  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name(name) }

  describe '#updated_content?' do
    it do
      expect(content.updated_content?).to be true
    end
  end

  describe '#published_at' do
    it do
      expect(content.published_at.to_s).to eq '2023-01-01 00:00:00 UTC'
    end
  end
end
