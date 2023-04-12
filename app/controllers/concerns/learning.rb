# module Learning
#   extend ActiveSupport::Concern

#   # @return [String]
#   def mod_name
#     params[:training_module_id]
#   end

#   # @return [String]
#   def content_name
#     params[:id]
#   end

#   # @return [Training::Module] shallow
#   def mod
#     Training::Module.by_name(mod_name)
#   end

#   # @return [Training::Page, Training::Video, Training::Question]
#   def content
#     mod.page_by_name(content_name)
#   end

#   def module_progress
#     ContentfulModuleOverviewDecorator.new(progress)
#   end

#   def progress_bar
#     ContentfulModuleProgressBarDecorator.new(progress)
#   end

#   def progress
#     helpers.cms_module_progress(mod)
#   end

# end
