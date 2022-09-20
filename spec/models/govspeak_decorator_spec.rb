require 'rails_helper'

RSpec.describe GovspeakDecorator do
  it 'passes a simple smoke test' do
    rendered = described_class.translate_markdown('*this is markdown*')
    expect(rendered).to eq "<p><em>this is markdown</em></p>\n"
  end

  it 'embeds YouTube  as iframe and without a title' do
    govspeak_md = '$YOUTUBE(ABCDEFGHIJ)$YOUTUBE'
    expected_html = %(<h2 class="govuk-heading-m govuk-!-margin-top-2"></h2>\n<div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="https://www.youtube.com/embed/ABCDEFGHIJ?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>\n)
    rendered = described_class.translate_markdown(govspeak_md)
    expect(rendered).to eq(expected_html)
  end

  it 'Youtube Embedding with title' do
    govspeak_md = '$YOUTUBE[Test title](EpjSlCJtPLo)$YOUTUBE'
    expected_html = %(<h2 class="govuk-heading-m govuk-!-margin-top-2">Video: Test title</h2>\n<div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="https://www.youtube.com/embed/EpjSlCJtPLo?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>\n)
    rendered = described_class.translate_markdown(govspeak_md)
    expect(rendered).to eq(expected_html)
  end

  it 'returns kramdown doc if sanitize false' do
    govspeak_md = '$YOUTUBE(EpjSlCJtPLos)$YOUTUBE'
    expected_html = %(<h2 class="govuk-heading-m govuk-!-margin-top-2"></h2>\n<div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="https://www.youtube.com/embed/EpjSlCJtPLos?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>\n)
    rendered = described_class.translate_markdown(govspeak_md, sanitize: false)
    expect(rendered).to eq(expected_html)
  end

  it 'embeds Vimeo  as iframe and without a title' do
    govspeak_md = '$VIMEO(123456789)$VIMEO'
    expected_html = %(<h2 class="govuk-heading-m govuk-!-margin-top-2"></h2>\n<div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="https://player.vimeo.com/video/123456789?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>\n)
    rendered = described_class.translate_markdown(govspeak_md)
    expect(rendered).to eq(expected_html)
  end

  it 'Vimeo Embedding with title' do
    govspeak_md = '$VIMEO[Test title](123456789)$VIMEO'
    expected_html = %(<h2 class="govuk-heading-m govuk-!-margin-top-2">Video: Test title</h2>\n<div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="https://player.vimeo.com/video/123456789?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>\n)
    rendered = described_class.translate_markdown(govspeak_md)
    expect(rendered).to eq(expected_html)
  end

  it 'returns kramdown doc if sanitize false' do
    govspeak_md = '$VIMEO(123456789)$VIMEO'
    expected_html = %(<h2 class="govuk-heading-m govuk-!-margin-top-2"></h2>\n<div class="govspeak-embed-container" style="padding:56.19% 0 0 0;position:relative;"><iframe class="govspeak-embed-video" style="position:absolute;top:0;left:0;width:100%;height:100%;" src="https://player.vimeo.com/video/123456789?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div>\n)
    rendered = described_class.translate_markdown(govspeak_md, sanitize: false)
    expect(rendered).to eq(expected_html)
  end
end
