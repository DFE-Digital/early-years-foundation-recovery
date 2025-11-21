# spec/controllers/home_controller_spec.rb
require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    let(:module_one) { double('ModuleOne', name: 'alpha', heading: 'Module Alpha', draft?: false) }
    let(:module_two) { double('ModuleTwo', name: 'beta', heading: 'Module Beta', draft?: false) }

    before do
      allow(Training::Module).to receive(:ordered).and_return([module_one, module_two])
    end

    context 'when user is logged in' do
      let(:user) { double('User') }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        get :index
      end

      it 'assigns public modules without overriding descriptions' do
        # Instead of assigns, access instance variable directly
        modules = controller.instance_variable_get(:@public_modules)
        expect(modules).to contain_exactly(module_one, module_two)

        # Should not attempt to override descriptions
        modules.each do |mod|
          expect(mod).not_to receive(:define_singleton_method)
        end
      end
    end

    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)

        # Stub I18n translations for custom descriptions
        allow(I18n).to receive(:t).with('training_module_custom_descriptions.alpha.description', default: '').and_return('Custom Alpha')
        allow(I18n).to receive(:t).with('training_module_custom_descriptions.beta.description', default: '').and_return('Custom Beta')

        # Allow define_singleton_method to be called on the doubles
        allow(module_one).to receive(:define_singleton_method)
        allow(module_two).to receive(:define_singleton_method)

        get :index
      end

      it 'assigns public modules with custom descriptions' do
        modules = controller.instance_variable_get(:@public_modules)
        expect(modules).to contain_exactly(module_one, module_two)

        # Verify description override was called
        expect(module_one).to have_received(:define_singleton_method).with(:description)
        expect(module_two).to have_received(:define_singleton_method).with(:description)
      end
    end
  end
end
