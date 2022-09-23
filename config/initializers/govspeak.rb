GOVSPEAK_TEMPLATES = {
  prompt: Slim::Template.new('app/views/govspeak/_prompt.html.slim'),
  youtube: Slim::Template.new('app/views/govspeak/_embedded_video.html.slim'),
  vimeo: Slim::Template.new('app/views/govspeak/_embedded_video.html.slim'),
}.freeze

# preload
I18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]

# Custom Practitioner Prompts
%i[info book brain].each do |icon|
  prompt_name = "prompt-#{icon}"
  prompt_code = Govspeak::Document.surrounded_by("$#{icon.upcase}")

  styles = []
  styles.push('prompt-bg') if icon.eql?(:book)

  Govspeak::Document.extension(prompt_name, prompt_code) do |content|
    locals = {
      icon: icon,
      styles: styles,
      heading: I18n.t(icon, scope: 'prompt'),
      body: Govspeak::Document.to_html(content),
    }

    GOVSPEAK_TEMPLATES[:prompt].render(nil, locals)
  end
end

# Youtube Embedded Videos
Govspeak::Document.extension('youtube', /\$YT(?:\[(.*?)\])?\((.*?)\)\$ENDYT/m) do |title, video|
  optional_title = title || ''
  params = { enablejsapi: 1, origin: ENV['DOMAIN'] }
  GOVSPEAK_TEMPLATES[:youtube].render(nil, title: optional_title, video: video, params: params.to_param, transcript: Govspeak::Document.to_html(transcript(video), sanitize: false), provider: 'youtube')
end

# Vimeo Embedded Videos
Govspeak::Document.extension('vimeo', /\$VM(?:\[(.*?)\])?\((.*?)\)\$ENDVM/m) do |title, video|
  optional_title = title || ''
  params = { enablejsapi: 1, origin: ENV['DOMAIN'] }
  GOVSPEAK_TEMPLATES[:vimeo].render(nil, title: optional_title, video: video, params: params.to_param, transcript: Govspeak::Document.to_html(transcript(video), sanitize: false), provider: 'vimeo')
end

# Video transcripts
def transcript(video)
  if File.exist?(Rails.root.join(%(data/video-transcripts/#{video}.yml)))
    transcript_file = Rails.root.join(%(data/video-transcripts/#{video}.yml))
    transcript_data = YAML.load_file(transcript_file)
    transcript_data['transcript']
  else
    'Transcript unavailable'
  end
end
