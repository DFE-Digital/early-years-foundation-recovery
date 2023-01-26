# rake --tasks eyfs:cms
#
namespace :eyfs do
  namespace :cms do
    desc 'Define Contentful entry models'
    task migrate: :environment do
      migrations = Dir[Rails.root.join('cms/migrate/*')]
      token = ContentfulRails.configuration.management_token
      space = ContentfulRails.configuration.space
      env = ContentfulRails.configuration.environment

      migrations.each do |file|
        system <<~CMD
          contentful space migration \
          --management-token #{token} \
          --space-id #{space} \
          --environment-id #{env} \
          --yes #{file}
        CMD
      end
    end

    # ./bin/docker-rails 'contentful:upload[alpha,bravo]'
    desc 'Populate from YAML'
    task :upload, [:mod_names] => :environment do |_task, args|
      require 'upload'
      uploader = Upload.new

      all_mods = TrainingModule.all.map(&:name)

      args.with_defaults(mod_names: all_mods)

      mod_names = args[:mod_names].split(',').flatten

      mod_names.each { |mod| uploader.call(mod_name: mod) }
    end
  end
end
