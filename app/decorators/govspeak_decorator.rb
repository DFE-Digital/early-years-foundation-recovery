class GovspeakDecorator < DelegateClass(Govspeak::Document)
  ALLOWED_TAGS = %w[details summary p h1 h2 h3 h4 ul li img div ol a span strong iframe].freeze

  def self.translate_markdown(markdown, sanitize: true)
    newdoc = new(Govspeak::Document.new(markdown, sanitize: sanitize, allowed_elements: ALLOWED_TAGS))
    newdoc.to_html
  end

  Govspeak::Document.extension('YoutubeVideo', /\$YoutubeVideo(?:\[(.*?)\])?\((.*?)\)\$EndYoutubeVideo/m) do |title, youtube_id|
    embed_url = %(https://www.youtube.com/embed/#{youtube_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
    optional_title = title ? %(title="#{title}") : ''
    %(<h1 class="govuk-heading-l govuk-!-margin-top-2"> Video: #{title} </h1><div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="#{embed_url}" #{optional_title} frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>)
  end


  Govspeak::Document.extension('VimeoVideo', /\$VimeoVideo(?:\[(.*?)\])?\((.*?)\)\$EndVimeoVideo/m) do |title, vimeo_id|
    embed_url = %(https://player.vimeo.com/video/#{vimeo_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
    optional_title = title ? %(title="#{title}") : ''
    %(<h1 class="govuk-heading-l govuk-!-margin-top-2"> Video: #{title} </h1><div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="#{embed_url}" #{optional_title} frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>)
  end

  Govspeak::Document.extension('VideoTranscript', /\$VideoTranscript(?:\[(.*?)\])?\((.*?)\)\$EndVideoTranscript/m) do |title, video_transcript_id|
    transcript_file = Rails.root.join(%(data/video-transcripts/#{video_transcript_id}.yml))
    optional_title = title ? %(title="#{title}") : ''
    transcript_data = YAML.load_file(transcript_file)
  end

  # TODO: Determine why commenting this method out has no affect on the specs
  # Find out what content is meant to be blocked/fixed by GovspeakDecorator::HtmlSanitizerDecorator
  def to_html
    @to_html ||= begin
      html = kramdown_doc.to_html
      Govspeak::PostProcessor.process(html, self)
    end
  end

  def kramdown_doc
    __getobj__.send('kramdown_doc')
  end

  # If you are using UJS then enable automatic nonce generation
  # Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

  # Set the nonce only to specific directives
  # Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

  # Report CSP violations to a specified URI
  # For further information see the following documentation:
  # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
  # Should only be used in development
  # Rails.application.config.content_security_policy_report_only = true
end
