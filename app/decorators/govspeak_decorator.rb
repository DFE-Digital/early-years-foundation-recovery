class GovspeakDecorator < DelegateClass(Govspeak::Document)
  ALLOWED_TAGS = %w[details summary p h1 h2 h3 h4 ul li img div ol a span strong iframe].freeze

  def self.translate_markdown(markdown, sanitize: true)
    newdoc = new(Govspeak::Document.new(markdown, sanitize: sanitize, allowed_elements: ALLOWED_TAGS))
    newdoc.to_html
  end

  Govspeak::Document.extension('YoutubeVideo', /\$YoutubeVideo(?:\[(.*?)\])?\((.*?)\)\$EndYoutubeVideo/m) do |title, youtube_link|
    youtube_id = youtube_link.scan(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/)[0][1]
    embed_url = %(https://www.youtube.com/embed/#{youtube_id}?enablejsapi=1&amp;origin=https://help-for-early-years-providers.education.gov.uk)
    optional_title = title ? %(title="#{title}") : ''
    %(<div class="govspeak-embed-container"><iframe class="govspeak-embed-video" src="#{embed_url}" #{optional_title} frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>)
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
