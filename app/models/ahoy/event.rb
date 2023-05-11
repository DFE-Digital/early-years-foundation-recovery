#
# Record user event transactions for key performance metrics
# @see ./data/KPI.md
#
class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods
  include ToCsv

  self.table_name = 'ahoy_events'

  belongs_to :visit
  belongs_to :user, optional: true

  scope :dashboard, -> { module_start.or(module_complete) }

  scope :user_registration, -> { where(name: 'user_registration') }

  scope :private_beta_registration, lambda {
    user_registration.where_properties(controller: 'extra_registrations')
  }

  scope :public_beta_registration, lambda {
                                     controllers = %w[
                                       registration/role_types
                                       registration/role_type_others
                                       registration/local_authorities
                                       registration/setting_types
                                     ]
                                     user_registration.where("properties -> 'controller' ?| array[:values]", values: controllers)
                                   }

  # @see ContentPagesController#track_events
  # ----------------------------------------------------------------------------
  scope :page_view, -> { where(name: 'module_content_page') }
  scope :module_start, -> { where(name: 'module_start') }
  scope :module_complete, -> { where(name: 'module_complete') }
  scope :confidence_check_complete, -> { where(name: 'confidence_check_complete') }

  # @param mod_names [Array<String, Symbol>] filter by TrainingModule names
  scope :where_module, lambda { |*mod_names|
    where("properties -> 'training_module_id' ?| array[:values]", values: mod_names)
  }
  # scope :where_module, lambda { |mod_name| where_properties(training_module_id: mod_name) }

  # @param types [Array<String, Symbol>] filter by ModuleItem types
  scope :where_page_type, lambda { |*types|
    page_view.where("properties -> 'type' ?| array[:values]", values: types)
  }

  # @see QuestionnairesController#track_events
  # ----------------------------------------------------------------------------
  scope :summative_assessment_start, -> { where(name: 'summative_assessment_start') }
  scope :confidence_check_start, -> { where(name: 'confidence_check_start') }

  # @see AssessmentResultsController#track_events
  # ----------------------------------------------------------------------------
  scope :summative_assessment_complete, -> { where(name: 'summative_assessment_complete') }

  # @param mod_name [String]
  scope :summative_assessment_fail, lambda { |mod_name|
    summative_assessment_complete.where_properties(training_module_id: mod_name, success: false)
  }

  # @param mod_name [String]
  scope :summative_assessment_pass, lambda { |mod_name|
    summative_assessment_complete.where_properties(training_module_id: mod_name, success: true)
  }
end
