require 'spec_helper'

describe 'ApplicationHelper', type: :helper do
  describe '#link_to_next_module_item' do
    let(:module_item) { ModuleItem.where(training_module: :test).to_a[-2] }
    let(:last_module_item) { ModuleItem.where(training_module: :test).to_a[-1] }

    it 'returns a link to the next content page' do
      link = helper.link_to_next_module_item(module_item)
      expect(link).to include(training_module_content_page_path(module_item.training_module, last_module_item))
    end

    context 'when module item is last item' do
      it 'returns a link to training modules root' do
        link = helper.link_to_next_module_item(module_item)
        expect(link).to include(training_modules_path)
      end
    end
  end

  describe '#link_to_previous_module_item' do
    let(:first_module_item) { ModuleItem.where(training_module: :test).to_a[0] }
    let(:second_module_item) { ModuleItem.where(training_module: :test).to_a[1] }

    it 'returns a link to the previous page' do
      link = helper.link_to_previous_module_item(second_module_item)
      expect(link).to include(training_module_content_page_path(first_module_item.training_module, first_module_item))
    end

    context 'when module item is first item' do
      it 'returns a link to training modules root' do
        link = helper.link_to_previous_module_item(first_module_item)
        expect(link).to include(training_modules_path)
      end
    end
  end
end
