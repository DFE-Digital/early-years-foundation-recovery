require "spec_helper"

describe "ContentHelper", type: :helper do

  describe "#translate_markdown" do
    it "returns text within p tags" do
      html = helper.translate_markdown("text")
      expect(html).to include("text")
      expect(html).to include("</p>")
    end

    it "translates markdown" do
      html = helper.translate_markdown("## text")
      expect(html).to include("text")
      expect(html).not_to include("</p>")
      expect(html).to include("</h2>")
    end
  end
end
