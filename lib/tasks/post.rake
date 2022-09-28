namespace :post do
  desc 'content page view backfill'
  task content: :environment do
    require 'fill_page_views'
    FillPageViews.new.call
  end
end

task post_release: ['db:prepare', 'post:content']
