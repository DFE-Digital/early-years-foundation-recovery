# Page model for pages with content shared by all modules
# whilst still able to render training_module/module_item specific variables
#
# Pagination is disabled for these pages
#
class CommonPage < ContentPage
  # @return [String]
  def heading
    I18n.t('heading', scope: type)
  end

  # @return [String]
  def body
    I18n.t('body', scope: type, **locals)
  end

  # @return [false]
  def page_numbers?
    false
  end

private

  # @return [Hash]
  def locals
    if module_item.assessment_intro?
      { passmark: passmark }
    elsif module_item.thankyou?
      { feedback_url: feedback_url }
    else
      {}
    end
  end

  # @return [Integer]
  def passmark
    module_item.parent.summative_threshold
  end

  # @return [String]
  def feedback_url
    "https://forms.office.com/Pages/ResponsePage.aspx?id=#{translate(:form)}"
  end
end
