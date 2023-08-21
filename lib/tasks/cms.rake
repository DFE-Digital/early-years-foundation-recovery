# rake --tasks eyfs:cms
#
namespace :eyfs do
  namespace :cms do
    # Support for Regexp
    #
    # ./bin/docker-rails 'eyfs:cms:search[practi(c|s)e]'
    #
    desc 'Query question answer labels'
    task :search, [:text] => :environment do |_task, args|
      Training::Module.ordered.map do |mod|
        puts ''
        puts mod.name
        puts '================='
        puts mod.answers_with(args[:text])
      end
    end

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

    desc 'Upload asset files to Contentful'
    task seed_images: :environment do
      require 'seed_images'
      SeedImages.new.call
    end

    # TODO: formalise user/learner/trainee terminology
    #
    # ./bin/docker-rails 'eyfs:cms:seed_learner_settings'
    desc 'Seed learner settings from YAML'
    task seed_learner_settings: :environment do
      require 'seed_learner_settings'
      SeedUserSettings.new.call
    end

    # ./bin/docker-rails 'eyfs:cms:seed_snippets'
    desc 'Seed microcopy resources from YAML'
    task seed_snippets: :environment do
      require 'seed_snippets'
      SeedSnippets.new.call
    end

    # @see .env
    #   CONTENTFUL_ENVIRONMENT=demo
    #
    # ./bin/docker-rails 'eyfs:cms:validate[alpha,bravo]'
    desc 'Validate CMS content'
    task :validate, [:mod_names] => :environment do |_task, args|
      args.with_defaults(mod_names: Training::Module.ordered.map(&:name))

      args[:mod_names].split(',').flatten.each do |mod|
        ContentfulDataIntegrity.new(module_name: mod).call
      rescue Dry::Types::ConstraintError
      end
    end

    desc 'Export happy E2E AST'
    task export: :environment do
      require 'content_test_schema'
      Training::Module.ordered.each do |mod|
        file_path = Rails.root.join("spec/support/ast/#{mod.name}.yml")
        file_data = ContentTestSchema.new(mod: mod).call.to_yaml

        File.write(file_path, file_data)
      end
    end
  end
end
