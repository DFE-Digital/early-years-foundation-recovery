class AddModuleContentType < ActiveRecord::Migration[7.0]
  def up
    create_content_type('module') do |ct|
      ct.field('title', :symbol)
      ct.field('depends on', :entry_array)
      ct.field('slug', :symbol)
      ct.field('thumbnail', :asset_link)
      ct.field('short description', :text)
      ct.field('description', :text)
      ct.field('duration', :number)
      ct.field('summative threshold', :number)
      ct.field('pages', :entry_array)
      ct.display_field = 'title'
    end

    create_content_type('page') do |ct|
      ct.field('heading', :text)
      ct.field('slug', :symbol)
      ct.field('body', :text)
      ct.field('notes', :boolean)
      ct.field('module id', :symbol)
      ct.field('component', :symbol)
      ct.display_field = 'heading'
    end

    create_content_type('question') do |ct|
      ct.field('body', :text)
      ct.field('slug', :symbol)
      ct.field('component', :symbol)
      ct.field('module id', :symbol)
      ct.field('assessment summary', :text)
      ct.field('assessment fail summary', :text)
      ct.field('answers', :entry_array)
      ct.field('multi select', :boolean)
      ct.display_field = 'body'
    end

    create_content_type('answer') do |ct|
      ct.field('body', :text)
      ct.field('correct', :boolean)
      ct.display_field = 'body'
    end

    create_content_type('confidence') do |ct|
      ct.field('body', :text)
      ct.field('slug', :symbol)
      ct.field('module id', :symbol)
      ct.display_field = 'body'
    end
  end

  def down; end
end
