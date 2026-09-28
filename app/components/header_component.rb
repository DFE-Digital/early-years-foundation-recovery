# frozen_string_literal: true

# Custom DfE header with a logo and account action links.
# Inherits the service navigation slot from GOV.UK Components.
# @see https://govuk-components.x-govuk.org/components/header/
class HeaderComponent < GovukComponent::HeaderComponent
  include Devise::Controllers::Helpers

  renders_many :action_links, 'ActionLinkItem'

  class ActionLinkItem < ViewComponent::Base
    def initialize(text:, href: nil, options: {})
      super()

      @text = text
      @href = href
      @options = options
    end

    def call
      if @href.present?
        helpers.govuk_link_to(@text, @href, **@options)
      else
        @text
      end
    end
  end
end
