require 'dry-types'

module Types
  include Dry.Types()
  include Dry::Core::Constants

  Parent = Instance(Training::Module) | Instance(Course)

  TrainingModule = Instance(Training::Module)
  TrainingContent = Instance(Training::Page) | Instance(Training::Question) | Instance(Training::Video)
end
