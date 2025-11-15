require 'rails_helper'

RSpec.describe Training::PagesController, type: :controller do
  let(:content_stub_class) do
    Struct.new(:submodule_intro, :thankyou, :certificate) do
      def submodule_intro? = submodule_intro
      def thankyou? = thankyou
      def certificate? = certificate
    end
  end

  before do
    sign_in create(:user, :registered)
  end

  describe '#ensure_module_started' do
    let(:module_name) { 'alpha' }

    let(:non_certificate_content) do
      Struct.new(:cert) { def certificate? = cert }.new(false)
    end

    let(:certificate_content) do
      Struct.new(:cert) { def certificate? = cert }.new(true)
    end

    before do
      allow(controller).to receive(:track)
      allow(controller.helpers).to receive(:calculate_module_state)
    end

    it 'tracks module_start and recalculates module state on first non-certificate page' do
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(true)

      controller.send(:ensure_module_started, content: non_certificate_content, module_name: module_name)

      expect(controller).to have_received(:track).with('module_start', training_module_id: module_name)
      expect(controller.helpers).to have_received(:calculate_module_state)
    end

    it 'does not track module_start again if already tracked' do
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)

      controller.send(:ensure_module_started, content: non_certificate_content, module_name: module_name)

      expect(controller).not_to have_received(:track).with('module_start', training_module_id: module_name)
      expect(controller.helpers).not_to have_received(:calculate_module_state)
    end

    it 'does not track module_start on certificate pages' do
      controller.send(:ensure_module_started, content: certificate_content, module_name: module_name)

      expect(controller).not_to have_received(:track).with('module_start', training_module_id: module_name)
    end
  end

  describe '#track_module_start?' do
    let(:module_name) { 'alpha' }
    let(:mod) { Struct.new(:name).new(module_name) }

    before do
      allow(controller).to receive(:mod).and_return(mod)
    end

    it 'returns true when on submodule intro page and module start is untracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new(true, false, false))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(true)

      expect(controller.send(:track_module_start?)).to be true
    end

    it 'returns false when not on a submodule intro page' do
      allow(controller).to receive(:content).and_return(content_stub_class.new(false, false, false))

      expect(controller.send(:track_module_start?)).to be false
    end

    it 'returns false when the module was already started' do
      allow(controller).to receive(:content).and_return(content_stub_class.new(true, false, false))
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)

      expect(controller.send(:track_module_start?)).to be false
    end
  end

  describe '#track_confidence_check_complete?' do
    let(:module_name) { 'alpha' }
    let(:mod) { Struct.new(:name).new(module_name) }

    before do
      allow(controller).to receive(:mod).and_return(mod)
    end

    it 'returns true when on thank you page and completion is untracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new(false, true, false))
      allow(controller).to receive(:untracked?).with('confidence_check_complete', training_module_id: module_name).and_return(true)

      expect(controller.send(:track_confidence_check_complete?)).to be true
    end

    it 'returns false when completion already tracked' do
      allow(controller).to receive(:content).and_return(content_stub_class.new(false, true, false))
      allow(controller).to receive(:untracked?).with('confidence_check_complete', training_module_id: module_name).and_return(false)

      expect(controller.send(:track_confidence_check_complete?)).to be false
    end

    it 'returns false when not on thank you page' do
      allow(controller).to receive(:content).and_return(content_stub_class.new(false, false, false))

      expect(controller.send(:track_confidence_check_complete?)).to be false
    end
  end

  describe '#module_complete_untracked?' do
    let(:module_name) { 'alpha' }
    let(:mod) { Struct.new(:name).new(module_name) }

    before do
      allow(controller).to receive(:mod).and_return(mod)
    end

    it 'returns false if module_start is still untracked' do
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(true)

      expect(controller.send(:module_complete_untracked?)).to be false
    end

    it 'returns true when module was started and module_complete is untracked' do
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)
      allow(controller).to receive(:untracked?).with('module_complete', training_module_id: module_name).and_return(true)

      expect(controller.send(:module_complete_untracked?)).to be true
    end

    it 'returns false when module_complete already tracked' do
      allow(controller).to receive(:untracked?).with('module_start', training_module_id: module_name).and_return(false)
      allow(controller).to receive(:untracked?).with('module_complete', training_module_id: module_name).and_return(false)

      expect(controller.send(:module_complete_untracked?)).to be false
    end
  end

  describe '#pdf?' do
    let(:pdf) { controller.send(:pdf?) }

    it 'returns false when the format is not PDF' do
      get :show, params: { training_module_id: 'alpha', id: '1-3-4' }
      expect(pdf).to be false
    end

    it 'returns true when the format is PDF' do
      get :show, params: { training_module_id: 'alpha', id: '1-3-4', format: 'pdf' }
    rescue ActionView::MissingTemplate
      expect(pdf).to be true
    end
  end
end
