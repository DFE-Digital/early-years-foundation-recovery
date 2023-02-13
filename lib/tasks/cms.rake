# rake --tasks eyfs:cms
#
namespace :eyfs do
  namespace :cms do
    # ./bin/docker-rails 'eyfs:cms:seed_static'
    desc 'Populate Contentful from YAML'
    task seed_static: :environment do
      require 'upload_static'
      UploadStatic.new.call(type: 'static')
    end
  end
end
