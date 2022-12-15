require 'rails_helper'

RSpec.describe Training::Page, type: :model do
  let(:module_id) { 'child-development-and-the-eyfs' }
  let(:page) { described_class.where(training_module: module_id).first }

  it 'loads expected data from contentful' do
    expect(page.slug).to eq('what-to-expect')
    expect(page.heading).to eq('What to expect during the training')
    expect(page.module_id).to eq('child-development-and-the-eyfs')
    expect(page.component).to eq('interruption_page')
  end

  # scopes ---------------------------------
  describe '.where_submodule_topic' do
    let!(:first_submodule_first_topic) { described_class.where(training_module: module_id, slug: '1-1-1').first }
    let!(:first_submodule_second_topic) { described_class.where(training_module: module_id, slug: '1-1-2').first }

    let!(:second_submodule_first_topic) { described_class.where(training_module: module_id, slug: '1-2-1').first }
    let!(:second_submodule_second_topic) { described_class.where(training_module: module_id, slug: '1-2-2').first }

    it 'returns module items matching the topic' do
      expect(described_class.where_submodule_topic(module_id, 1, 1)).to include(first_submodule_first_topic)
      expect(described_class.where_submodule_topic(module_id, 1, 2)).to include(first_submodule_second_topic)
    end

    it 'does not return items from other topics' do
      expect(described_class.where_submodule_topic(module_id, 1, 1)).not_to include(first_submodule_second_topic)
      expect(described_class.where_submodule_topic(module_id, 1, 1)).not_to include(second_submodule_first_topic)
      expect(described_class.where_submodule_topic(module_id, 1, 2)).not_to include(first_submodule_first_topic)
      expect(described_class.where_submodule_topic(module_id, 1, 2)).not_to include(second_submodule_second_topic)
    end
  end

  # sequence ---------------------------------

  describe '#next_item' do
    let(:next_page) { described_class.where(training_module: module_id).load.to_a[1] }

    it 'returns the next module item' do
      expect(page.next_item).to eq(next_page)
    end

    context 'when item is last item' do
      let(:last_page) { described_class.where(training_module: module_id).load.last }

      it 'returns nil' do
        expect(last_page.next_item).to be_nil
      end
    end
  end

  describe '#previous_item' do
    let(:first_module_item) { page }
    let(:second_module_item) { described_class.where(training_module: module_id).load.to_a[1] }

    it 'returns the previous module item' do
      expect(second_module_item.previous_item).to eq(first_module_item)
    end

    context 'when item is first item' do
      it 'returns nil' do
        expect(first_module_item.previous_item).to be_nil
      end
    end
  end

  # names ---------------------------------

  describe '#topic_name' do
    let(:page) { Training::Page.where(training_module: module_id, slug: '1-2-2').first }

    it 'extracts the topic number from the name' do
      expect(page.topic_name).to eq('2')
    end

    context 'with topic subpage' do
      let(:page) { Training::Page.where(training_module: module_id, slug: '1-2-1-3').first } 

      it 'extracts the topic number from the name' do
        expect(page.topic_name).to eq('1')
      end
    end
  end

  # position ---------------------------------

  describe '#position_within_topic' do
    let!(:topic_item_one) { described_class.where(training_module: module_id, slug: '1-1-1').first }
    let!(:topic_item_two) { described_class.where(training_module: module_id, slug: '1-1-1-1').first }
    let!(:topic_item_three) { described_class.where(training_module: module_id, slug: '1-1-1-2').first }

    it 'returns the position of the item within the topic' do
      expect(topic_item_one.position_within_topic).to eq(0)
      expect(topic_item_two.position_within_topic).to eq(1)
    end

    it 'uses position in array rather than last digit in name' do
      expect(topic_item_three.position_within_topic).to eq(3)
    end
  end

  describe '#position_within_module' do
    let(:first_item) { Training::Module.find_by(slug: module_id).first.pages.first }
    let(:last_item) { Training::Module.find_by(slug: module_id).first.pages.last }

    it 'return position in array of module items in training module' do
      expect(first_item.position_within_module).to eq(0)
      expect(last_item.position_within_module).to eq(Training::Module.find_by(slug: module_id).first.pages.count - 1)
    end
  end

  # common page ------------------------------

  subject(:common_page) do
    described_class.find_by(module_id: module_id, component: :confidence_intro, slug: '1-3-2').first
  end

  it '#heading' do
    expect(common_page.heading).to eq 'Reflect on your learning'
  end

  it '#body' do
    expect(common_page.body).to include 'To help DfE to measure our impact'
  end
  
  # content page -----------------------------

  subject(:content_page) do
    described_class.find_by(module_id: module_id, component: :text_page, slug: '1-1-1').first
  end

  it '#heading' do
    expect(content_page.heading).to eq 'The importance of understanding child development'
  end

  it '#body' do
    expect(content_page.body).to include 'Understanding how children develop will help you to plan and implement an early years curriculum that promotes inclusion and progress for all.'
  end

  it '#notes?' do
    expect(content_page).not_to be_notes
  end

  it '#page_numbers?' do
    expect(content_page).to be_page_numbers
  end

  # pagination -------------------------------

  it '#pagination' do
    expect(content_page.pagination).to eq({current: 1, total: 29})
  end

end
