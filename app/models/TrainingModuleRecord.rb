class TrainingModuleRecord < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
