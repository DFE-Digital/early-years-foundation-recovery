# rake --tasks contentful
#
namespace :contentful do
  # ./bin/docker-rails 'contentful:upload[alpha]'
  desc 'Upload modules'
  task :upload, [:mod_names] => :environment do |_task, args|
    require 'upload'
    uploader = Upload.new

    args.with_defaults(mod_names: %w[alpha bravo charlie delta])

    mod_names = args[:mod_names].split(',').flatten

    mod_names.each { |mod| uploader.call(mod_name: mod) }
  end
end
