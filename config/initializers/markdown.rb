# https://github.com/vmg/redcarpet



class CustomPreprocessor < GovukMarkdown::Preprocessor

  def button
    @output = output.gsub(build_regexp('button')) do

      content = Regexp.last_match(1)

      content.match(%r"\[(.*)\]\((.*)\)")

      link = Regexp.last_match(1)
      text = Regexp.last_match(2)

      <<~HTML
        <a href=#{link} class="govuk-link govuk-button">
          #{text}
        </a>
      HTML
    end
    self
  end

  def quote
    @output = output.gsub(build_regexp('quote')) do

      content = Regexp.last_match(1)
      citation = content.split("\n").last
      quote = content.gsub(citation, Types::EMPTY_STRING)

      locals = {
        quote: nested_markdown(quote),
        citation: citation,
      }

      template = Slim::Template.new('app/views/govspeak/_quote.html.slim')
      template.render(nil, locals)
    end
    self
  end

  def brain
    @output =
      output.gsub(build_regexp('brain')) do
        learning_prompt('brain', Regexp.last_match(1))
      end
    self
  end

  def book
    @output =
      output.gsub(build_regexp('book')) do
        learning_prompt('book', Regexp.last_match(1))
      end
    self
  end

  private

  def learning_prompt(type, content)
    template = Slim::Template.new('app/views/govspeak/_prompt.html.slim')
    template.render(nil, icon: type, body: nested_markdown(content))
  end
end






class CustomRenderer < GovukMarkdown::Renderer
  include Redcarpet::Render::SmartyPants

  # smarty
  # def postprocess(document)
  # end

  def preprocess(document)
    CustomPreprocessor
      .new(document)
      .inject_inset_text
      .inject_details
      .button
      .brain
      .book
      .quote
      .output
  end
end






module CustomMarkdown
  def self.render(markdown, options = {})
    renderer = CustomRenderer.new(options, { with_toc_data: true, link_attributes: { class: 'govuk-link' } })
    Redcarpet::Markdown.new(renderer, tables: true, no_intra_emphasis: true).render(markdown).strip
  end
end
