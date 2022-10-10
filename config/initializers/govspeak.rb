GOVSPEAK_TEMPLATES = {
  prompt: Slim::Template.new('app/views/govspeak/_prompt.html.slim'),
  video: Slim::Template.new('app/views/govspeak/_video.html.slim'),
}.freeze

# Custom Practitioner Prompts
%i[info book brain].each do |icon|
  prompt_name = "prompt-#{icon}"
  prompt_code = Govspeak::Document.surrounded_by("$#{icon.upcase}")

  styles = []
  styles.push('prompt-bg') if icon.eql?(:brain) # reflection point

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

# Youtube Videos
Govspeak::Document.extension('youtube', /\$YT(?:\[(.*?)\])?\((.*?)\)\$ENDYT/m) do |title, video|
  params = { enablejsapi: 1, origin: ENV['DOMAIN'] }.to_param

  locals = {
    title: title,
    url: "https://www.youtube.com/embed/#{video}?#{params}",
  }

  GOVSPEAK_TEMPLATES[:video].render(nil, locals)
end

# Vimeo Videos
Govspeak::Document.extension('vimeo', /\$VM(?:\[(.*?)\])?\((.*?)\)\$ENDVM/m) do |title, video|
  params = { enablejsapi: 1, origin: ENV['DOMAIN'] }.to_param

  locals = {
    title: title,
    url: "https://player.vimeo.com/video/#{video}?#{params}",
  }

  GOVSPEAK_TEMPLATES[:video].render(nil, locals)
end
