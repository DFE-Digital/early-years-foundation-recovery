# rake --tasks eyfs:cms
#
namespace :eyfs do
  namespace :cms do
    # ./bin/docker-rails 'eyfs:cms:seed'
    desc 'Populate Contentful from YAML'
    task seed: :environment do
      require 'upload'
      uploader = Upload.new
      uploader.call(type: 'static')
    end
  end
end
