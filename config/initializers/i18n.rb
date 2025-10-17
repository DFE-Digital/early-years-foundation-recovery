# @see https://github.com/ruby-i18n/i18n/wiki/Fallbacks
# require 'i18n/backend/fallbacks'
# I18n::Backend::Simple.include I18n::Backend::Fallbacks

# Contentful powered locales using `Resource` model
#
# @see https://github.com/ruby-i18n/i18n/wiki/Backend
module I18n::Backend::Content
  # @return [String, Hash, nil] The translation from Contentful if present, else the original YAML
  def lookup(locale, key, scope = [], options = {})
    original = super
    full_key = scope ? Array(scope).push(key).join('.') : key

    # Fetch Contentful resource if it exists
    resource = find_resource(full_key)
    contentful_value = resource&.body

    # Case 1: No Contentful resource → return original
    return original if contentful_value.nil?

    # Case 2: Original YAML is a hash → preserve it (do not override)
    return original if original.is_a?(Hash) && contentful_value.is_a?(String)

    # Case 3: Contentful exists → return it
    contentful_value
  end

private

  # @return [Page::Resource, nil]
  def find_resource(full_key)
    Page::Resource.by_name(full_key)
  end
end

I18n::Backend::Simple.include I18n::Backend::Content
