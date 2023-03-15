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

    # ./bin/docker-rails 'eyfs:cms:seed[alpha,bravo]'
    desc 'Populate Contentful from YAML'
    task :seed, [:mod_names] => :environment do |_task, args|
      # TODO: rename function
      require 'upload'
      uploader = Upload.new

      all_mods = TrainingModule.all.map(&:name)

      args.with_defaults(mod_names: all_mods)

      mod_names = args[:mod_names].split(',').flatten

      mod_names.each { |mod| uploader.call(mod_name: mod) }
    end

    # desc 'Upload asset files to Contentful'
    # task upload: :environment do
    #   binding.pry
    # end

    # @see .env
    #   CONTENTFUL_ENVIRONMENT=demo
    #
    # ./bin/docker-rails 'eyfs:cms:validate[alpha,bravo]'
    desc 'Validate CMS content'
    task :validate, [:mod_names] => :environment do |_task, args|
      ENV['CONTENTFUL_CACHE'] = 'y'

      # Oddly this is needed even though ContentfulRails is also configured
      ContentfulModel.use_preview_api = Rails.application.preview?

      args.with_defaults(mod_names: Training::Module.ordered.map(&:name))

      args[:mod_names].split(',').flatten.each do |mod|
        ContentfulDataIntegrity.new(module_name: mod).call
      end
    end
  end
end
