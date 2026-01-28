require 'rails_helper'

RSpec.describe Training::PagesController, type: :controller do
  let(:content_stub_class) do
    Struct.new(:name, :submodule_intro, :thankyou, :certificate) do
      def submodule_intro? = submodule_intro
      def thankyou? = thankyou
      def certificate? = certificate
    end
  end

  let(:user) { create(:user, :registered) }
  let(:module_name) { 'alpha' }
  let(:mod) { Struct.new(:name).new(module_name) }

  before do
    sign_in user
    allow(controller).to receive(:mod).and_return(mod)
  end

  describe '#track_module_start?' do
    it 'returns true when on submodule intro page and module_start is untracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-1', true, false, false))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(true)

      expect(controller.send(:track_module_start?)).to be true
    end

    it 'returns false when not on a submodule intro page' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-1-1', false, false, false))

      expect(controller.send(:track_module_start?)).to be false
    end

    it 'returns false when the module_start event was already tracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-1', true, false, false))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)

      expect(controller.send(:track_module_start?)).to be false
    end
  end

  describe '#track_confidence_check_complete?' do
    it 'returns true when on thank you page and completion is untracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-3-3', false, true, false))
      allow(controller).to receive(:untracked?).with('confidence_check_complete', training_module_id: module_name).and_return(true)

      expect(controller.send(:track_confidence_check_complete?)).to be true
    end

    it 'returns false when completion already tracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-3-3', false, true, false))
      allow(controller).to receive(:untracked?).with('confidence_check_complete', training_module_id: module_name).and_return(false)

      expect(controller.send(:track_confidence_check_complete?)).to be false
    end

    it 'returns false when not on thank you page' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-1-1', false, false, false))

      expect(controller.send(:track_confidence_check_complete?)).to be false
    end
  end

  describe '#track_module_complete?' do
    it 'returns false if not on certificate page' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-1-1', false, false, false))

      expect(controller.send(:track_module_complete?)).to be false
    end

    it 'returns true when on certificate page and module_start was tracked but module_complete is not' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-3-4', false, false, true))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)
      allow(controller).to receive(:untracked?).with('module_complete', training_module_id: module_name).and_return(true)

      expect(controller.send(:track_module_complete?)).to be true
    end

    it 'returns false when module_complete already tracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-3-4', false, false, true))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)
      allow(controller).to receive(:untracked?).with('module_complete', training_module_id: module_name).and_return(false)

      expect(controller.send(:track_module_complete?)).to be false
    end

    it 'returns false if module_start was never tracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new('1-3-4', false, false, true))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(true)

      expect(controller.send(:track_module_complete?)).to be false
    end
  end

  describe '#pdf?' do
    it 'returns false when the URL does not end with .pdf' do
      allow(controller.request).to receive(:original_url).and_return('http://test.host/modules/alpha/content-pages/1-3-4')

      expect(controller.send(:pdf?)).to be false
    end

    it 'returns true when the URL ends with .pdf' do
      allow(controller.request).to receive(:original_url).and_return('http://test.host/modules/alpha/content-pages/1-3-4.pdf')

      expect(controller.send(:pdf?)).to be true
    end
  end

  describe '#record_module_completion' do
    it 'calls UserModuleProgress.record_completion' do
      expect(UserModuleProgress).to receive(:record_completion).with(user: user, module_name: module_name)

      controller.send(:record_module_completion)
    end
  end

  describe '#record_page_view' do
    let(:content) { content_stub_class.new('1-1-1', false, false, false) }

    before do
      allow(controller).to receive(:content).and_return(content)
    end

    it 'calls UserModuleProgress.record_page_view' do
      expect(UserModuleProgress).to receive(:record_page_view).with(
        user: user,
        module_name: module_name,
        page_name: '1-1-1',
      )

      controller.send(:record_page_view)
    end
  end
end
