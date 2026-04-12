FactoryBot.define do
  factory :video, class: 'Training::Video' do
    id { '5VQGsJeTwQSx4M2fxZeKRq' }
    name { '1-2-1-2' }
    video_id { 'XnP6jaK7ZAY' }
    video_provider { 'youtube' }
    title { 'Youtube Video Title' }
    heading { 'Test Video Heading' }
    page_type { 'video_page' }
    transcript { "Today's subject is based on..." }
    parent_id { '4u49zTRJzYAWsBI6CitwN4' } # default for all videos
    published_at { Time.zone.parse('2023-01-01 00:00:00 UTC') }

    trait :vimeo do
      video_id { '743243040' }
      video_provider { 'vimeo' }
      title { 'Vimeo Video Title' }
    end

    factory :debug_video do
      id { 'LaZ22OwFuaFuXRjVvNLwy' }
      name { '1-2-1-2' }
      parent_id { '4u49zTRJzYAWsBI6CitwN4' }
      video_id { 'XnP6jaK7ZAY' }
      video_provider { 'youtube' }
      title { 'Youtube Video Title' }
      page_type { 'video_page' }
      transcript { "Today's subject is based on..." }
      published_at { nil }
    end

    initialize_with do
      mod_id = parent_id.presence || 'training-module-factory-id'
      sys = {
        'id' => id || 'video-factory-id',
        'type' => 'Entry',
        'contentType' => { 'sys' => { 'id' => 'video' } },
      }
      fields = {
        'name' => { 'en-US' => name },
        'video_id' => { 'en-US' => video_id },
        'video_provider' => { 'en-US' => video_provider },
        'title' => { 'en-US' => title },
        'heading' => { 'en-US' => heading },
        'page_type' => { 'en-US' => page_type },
        'transcript' => { 'en-US' => transcript },
        'module' => {
          'en-US' => {
            'sys' => {
              'type' => 'Link',
              'linkType' => 'Entry',
              'id' => mod_id,
            },
          },
        },
        'published_at' => { 'en-US' => published_at },
      }
      # Ensure all nested hashes are present and not nil
      fields.each do |k, v|
        fields[k] = { 'en-US' => '' } if v.nil?
      end
      Training::Video.new({ 'sys' => sys, 'fields' => fields })
    end
  end
end
