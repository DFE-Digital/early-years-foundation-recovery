# rake --tasks contentful
#
namespace :contentful do
  desc 'Upload modules'
  task upload: :environment do
    require 'upload'
    Upload.call('alpha')
  end
end
