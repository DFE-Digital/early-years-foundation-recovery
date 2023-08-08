# frozen_string_literal: true

class HeaderComponent < GovukComponent::HeaderComponent
  include Devise::Controllers::Helpers

private

  def default_attributes
    { class: %w[dfe-header] }
  end

  def navigation_html_attributes
    nc = %w[dfe-header__navigation] << custom_navigation_classes.compact

    { id: 'header-navigation', class: nc, aria: { label: navigation_label, labelledby: 'label-navigation' } }
  end

  def container_html_attributes
    { class: %w[dfe-header__container dfe-width-container] << custom_container_classes.compact }
  end

  def crown_fallback_image_attributes
    {
      class: 'dfe-header__logo-crown-fallback-image',
      width: '36',
      height: '32',
    }
  end

  class NavigationItem < GovukComponent::HeaderComponent::NavigationItem
    def active_class
      ['dfe-header__navigation-item--current'] if active?
    end

    def call
      tag.li(**html_attributes) do
        if link?
          link_to(text, href, class: 'dfe-header__navigation-link', **options)
        else
          text
        end
      end
    end

  private
    
    def default_attributes
      { class: %w[dfe-header__navigation-item] }
    end
  end
end
