module Contentfully
  extend ActiveSupport::Concern

  # TODO: deprecate these ------------------------------------------------------

  def training_module
    mod
  end

  def module_item
    @module_item ||= content
  end

  # ----------------------------------------------------------------------------

  # @return [String]
  def mod_name
    params[:training_module_id]
  end

  # @return [String]
  def content_slug
    params[:id]
  end

  # @return [Training::Module] shallow
  def mod
    @mod ||= Training::Module.by_name(mod_name)
  end

  # @return [Training::Content]
  def content
    @content ||= mod.page_by_name(content_slug)
  end

  # ----------------------------------------------------------------------------
end
