# @see https://github.com/ruby-i18n/i18n/wiki/Fallbacks
# require 'i18n/backend/fallbacks'
# I18n::Backend::Simple.include I18n::Backend::Fallbacks

# Contentful powered locales using `Resource` model
#
# @see https://github.com/ruby-i18n/i18n/wiki/Backend
module I18n::Backend::Content
  # @return [String, Hash, nil]
  def lookup(locale, key, scope = [], options = {})
    full_key = Array(scope).push(key).join('.')

    # Only intercept registration_form_banners keys
    if full_key.start_with?('registration_form_banners.')
      # First try CMS resource
      resource_body = find_resource(full_key)&.body

      if resource_body.is_a?(Hash)
        return resource_body
      elsif resource_body.nil?
        # fallback to YAML
        original = super
        return original if original.is_a?(Hash)
      end
    end

    # Default behavior for everything else
    super
  end
end

I18n::Backend::Simple.include I18n::Backend::Content
