# https://github.com/vmg/redcarpet

class CustomPreprocessor < GovukMarkdown::Preprocessor
  # @return [CustomPreprocessor]
  def apply_all
    inject_inset_text.inject_details.button.external.quote.brain.book.info
  end

  # @example
  #   {button}[Continue](/path/to/page){/button}
  #
  # @return [CustomPreprocessor]
  def button
    @output = output.gsub(build_regexp('button')) do
      text, link = hyperlink(Regexp.last_match(1))

      <<~HTML
        <a href=#{link} class="govuk-link govuk-button">
        #{text}
        </a>
      HTML
    end
    self
  end

  # @example
  #   {external}[Read more](https://example.com){/external}
  #
  # @return [CustomPreprocessor]
  def external
    @output = output.gsub(build_regexp('external')) do
      text, link = hyperlink(Regexp.last_match(1))

      <<~HTML
        <a href=#{link} class="govuk-link" target="_blank" rel="noopener noreferrer">
        #{text} (opens in new tab)
        </a>
      HTML
    end
    self
  end

  # @example
  #   {quote}
  #   This is the quote
  #
  #   This is the citation
  #   {/quote}
  #
  # @return [CustomPreprocessor]
  def quote
    @output = output.gsub(build_regexp('quote')) do
      content = Regexp.last_match(1)
      citation = content.split("\n").last
      quote = content.gsub(citation, Types::EMPTY_STRING)

      quote_template.render(nil, quote: nested_markdown(quote), citation: citation)
    end
    self
  end

  # @return [CustomPreprocessor]
  def brain
    @output =
      output.gsub(build_regexp('brain')) do
        learning_prompt('brain', Regexp.last_match(1))
      end
    self
  end

  # @return [CustomPreprocessor]
  def book
    @output =
      output.gsub(build_regexp('book')) do
        learning_prompt('book', Regexp.last_match(1))
      end
    self
  end

  # @return [CustomPreprocessor]
  def info
    @output =
      output.gsub(build_regexp('info')) do
        learning_prompt('info', Regexp.last_match(1))
      end
    self
  end

private

  # @param content [String]
  # @return [Array<String>]
  def hyperlink(content)
    content =~ %r{\[(.*)\]\((.*)\)}
    [Regexp.last_match(1), Regexp.last_match(2)]
  end

  # @param type [String]
  # @param content [String]
  # @return [String]
  def learning_prompt(type, content)
    prompt_template.render(nil, icon: type, body: nested_markdown(content))
  end

  # @return [Slim::Template]
  def prompt_template
    @prompt_template ||= Slim::Template.new('app/views/markup/_prompt.html.slim')
  end

  # @return [Slim::Template]
  def quote_template
    @quote_template ||= Slim::Template.new('app/views/markup/_quote.html.slim')
  end
end

class CustomRenderer < GovukMarkdown::Renderer
  include Redcarpet::Render::SmartyPants

  # @param document [String]
  # @return [String]
  def preprocess(document)
    CustomPreprocessor.new(document).apply_all.output
  end
end

module CustomMarkdown
  def self.render(markdown, **options)
    renderer = CustomRenderer.new(options, { with_toc_data: true, link_attributes: { class: 'govuk-link' } })
    Redcarpet::Markdown.new(renderer, tables: true, no_intra_emphasis: true).render(markdown).strip
  end
end
