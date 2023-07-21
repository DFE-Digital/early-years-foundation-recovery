# https://github.com/ruby-i18n/i18n/wiki/Fallbacks
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.include I18n::Backend::Fallbacks

# https://github.com/ruby-i18n/i18n/wiki/Backend
module I18n::Backend::Content
  def lookup(locale, key, scope = [], separator = nil)
    resource_name = scope ? Array(scope).push(key).join('.') : key
    resource = Page::Resource.by_name(resource_name)
    resource&.body || super
  end
end

I18n::Backend::Simple.include I18n::Backend::Content

# > A blockquote with a title
# {:title="The blockquote title"}
# {: #myid .class1 .class2}

# <https://kramdown.gettalong.org/quickref.html#html-elements>
