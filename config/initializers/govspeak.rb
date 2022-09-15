GOVSPEAK_TEMPLATES = {
  prompt: Slim::Template.new('app/views/govspeak/_prompt.html.slim'),
  youtube: Slim::Template.new('app/views/govspeak/_youtube.html.slim'),
  # vimeo: Slim::Template.new('app/views/govspeak/_vimeo.html.slim'),
}.freeze

GOVSPEAK_ICONS = {
  bang: 'exclamation',
  book: 'book',
  brain: 'brain',
}.freeze

# preload
I18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]

# Custom Practitioner Prompts
GOVSPEAK_ICONS.each do |type, icon|
  prompt_name = "prompt-#{type}"
  prompt_code = Govspeak::Document.surrounded_by("$#{type.upcase}")

  styles = []
  styles.push('green') if icon.eql?('book')

  Govspeak::Document.extension(prompt_name, prompt_code) do |content|
    locals = {
      icon: icon,
      styles: styles,
      heading: I18n.t(type, scope: 'prompt'),
      body: Govspeak::Document.to_html(content),
    }

    GOVSPEAK_TEMPLATES[:prompt].render(nil, locals)
  end
end

# Youtube Embeded Videos
Govspeak::Document.extension('youtube', /\$YT(?:\[(.*?)\])?\((.*?)\)\$ENDYT/m) do |title, video|
  params = { enablejsapi: 1, origin: ENV['DOMAIN'] }
  GOVSPEAK_TEMPLATES[:youtube].render(nil, title: title, video: video, params: params.to_param)
end

Govspeak::Document.extension('YoutubeVideo', /\$YoutubeVideo(?:\[(.*?)\])?\((.*?)\)\$EndYoutubeVideo/m) do |title, youtube_link|
  youtube_id = youtube_link.scan(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/)[0][1]
  embed_url = %(https://www.youtube.com/embed/#{youtube_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
  optional_title = title ? %(title="#{title}") : ''
  %(<div class="govspeak-embed-container"><iframe class="govspeak-embed-video" src="#{embed_url}" #{optional_title} frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>)
end
