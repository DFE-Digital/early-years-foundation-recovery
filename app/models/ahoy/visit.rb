class Ahoy::Visit < ApplicationRecord
  include ToCsv

  self.table_name = 'ahoy_visits'

  has_many :events, class_name: 'Ahoy::Event'
  belongs_to :user, optional: true
end
