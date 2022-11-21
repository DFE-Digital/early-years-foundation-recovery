# Compare page names in the data and locales YAML files and report gaps
#
RSpec::Matchers.define :be_publishable do |_|
  match do |mod_name|
    module_content[mod_name].count.eql?(page_content[mod_name].count)
  end

  failure_message do |mod_name|
    missing_locales = module_content[mod_name].difference(page_content[mod_name])
    missing_data = page_content[mod_name].difference(module_content[mod_name])

    if !missing_locales.empty?
      "#{mod_name} needs #{missing_locales.to_sentence} added to /config/locales/modules/#{mod_name}.yml"
    elsif !missing_data.empty?
      "#{mod_name} needs #{missing_data.to_sentence} added to /data/modules/#{mod_name}.yml"
    end
  end

  description do
    'ready to be published'
  end
end

# Confirm all essential ModuleItem types are present
#
RSpec::Matchers.define :have_all_types do |_|
  match do |mod_name|
    module_types[mod_name].uniq.sort.eql?(essential_types.sort)
  end

  failure_message do |mod_name|
    missing_types = essential_types.difference(module_types[mod_name].uniq)

    "#{mod_name} is missing #{missing_types.to_sentence}"
  end

  description do
    'contains all necessary page types'
  end
end
