require 'rails_helper'

describe 'LinkHelper', type: :helper do
  let(:module_items) { ModuleItem.where(training_module: :alpha) }

  describe '#link_to_next_module_item' do
    let(:module_item) { module_items.to_a[-3] }
    let(:last_module_item) { module_items.to_a[-2] }

    it 'returns a link to the next content page' do
      link = helper.link_to_next_module_item(module_item)
      expect(link).to include(training_module_content_page_path(module_item.training_module, last_module_item))
    end

    context 'when module item is last item' do
      it 'returns a link to training modules root' do
        link = helper.link_to_next_module_item(last_module_item)
        expect(link).to include('1-3-4')
      end
    end
  end

  describe '#link_to_previous_module_item' do
    let(:first_module_item) { module_items.to_a[0] }
    let(:second_module_item) { module_items.to_a[1] }

    it 'returns a link to the previous page' do
      link = helper.link_to_previous_module_item(second_module_item)
      expect(link).to include(training_module_content_page_path(first_module_item.training_module, first_module_item))
    end

    context 'when module item is first item' do
      it 'returns a link to training modules root' do
        link = helper.link_to_previous_module_item(first_module_item)
        expect(link).to include(training_module_path(first_module_item.training_module))
      end
    end
  end

  # describe '#link_to_retake_or_results'
  # end

  # describe '#link_to_action'
  # end
end
