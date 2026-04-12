FactoryBot.define do
  factory :training_module, class: 'Training::Module' do
    id { '6EczqUOpieKis8imYPc6mG' }
    name { 'alpha' }
    heading { 'Test Module Heading' }

    initialize_with do
      mod_id = id || 'training-module-factory-id'
      sys = {
        'id' => mod_id,
        'type' => 'Entry',
        'contentType' => { 'sys' => { 'id' => 'trainingModule' } },
      }
      fields = {
        'name' => { 'en-US' => name },
        'heading' => { 'en-US' => heading },
      }
      fields.each do |k, v|
        fields[k] = { 'en-US' => '' } if v.nil?
      end
      Training::Module.new({ 'sys' => sys, 'fields' => fields })
    end

    factory :bravo_module do
      id { '4u49zTRJzYAWsBI6CitwN4' }
      name { 'bravo' }
    end
  end
end
