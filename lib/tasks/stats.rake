require 'reporting'

namespace :eyfs do
  namespace :report do
    include Reporting

    desc 'print stats to console [YAML]'
    task stats: :environment do
      puts users.to_yaml
      puts modules.to_yaml
    end

    desc 'export stats to file [CSV]'
    task export: :environment do
      export_users
      export_modules
    end
  end
end
