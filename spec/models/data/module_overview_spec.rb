require 'rails_helper'

# module Data
#     class ModuleOverview
#       include ToCsv
  
#       def self.column_names
#         [
#           'Module Name',
#           'Total Users',
#           'Not Started',
#           'Started',
#           'In Progress',
#           'Completed',
#           'True/False',
#           'Module Start',
#           'Module Complete',
#           'Confidence Check Start',
#           'Confidence Check Complete',
#           'Start Assessment',
#           'Pass Assessment',
#           'Fail Assessment'
#         ]
#       end
  
#       def self.dashboard
#         data = data_hash
#         mods.map do |mod|
#             data[:module_name] << mod.name
#             data[:total_users] << User.count
#             data[:not_started] << not_started(mod)
#             data[:started] << started(mod)
#             data[:in_progress] << in_progress(mod)
#             data[:completed] << completed(mod)
#             data[:true_false] << true_false_count(mod)
#             data[:module_start] << Ahoy::Event.module_start.where_module(mod.name).count
#             data[:module_complete] << Ahoy::Event.module_complete.where_module(mod.name).count
#             data[:confidence_check_start] << Ahoy::Event.confidence_check_start.where_module(mod.name).count
#             data[:confidence_check_complete] << Ahoy::Event.confidence_check_complete.where_module(mod.name).count
#             data[:start_assessment] << Ahoy::Event.summative_assessment_start.where_module(mod.name).count
#             data[:pass_assessment] << Ahoy::Event.summative_assessment_pass(mod.name).count
#             data[:fail_assessment] << Ahoy::Event.summative_assessment_fail(mod.name).count
#         end

#         data
#       end
  
#       def self.mods
#         if Rails.application.cms?
#           Training::Module.ordered
#         else
#           TrainingModule.published
#         end
#       end
  
#       def self.true_false_count(mod)
#         return 'N/A' unless Rails.application.cms?
  
#         mod.questions.count(&:true_false?)
#       end
  
#       def self.not_started(mod)
#         User.all.map { |u| u.module_time_to_completion[mod.name] }.count(&:nil?)
#       end
  
#       def self.in_progress(mod)
#         User.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:zero?)
#       end
  
#       def self.completed(mod)
#         User.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:positive?)
#       end
  
#       def self.started(mod)
#         in_progress(mod) + completed(mod)
#       end
#     end
#   end
  

RSpec.describe Data::ModuleOverview do

    let(:headers) do
        [
            'Module Name',
            'Total Users',
            'Not Started',
            'Started',
            'In Progress',
            'Completed',
            'True/False',
            'Module Start',
            'Module Complete',
            'Confidence Check Start',
            'Confidence Check Complete',
            'Start Assessment',
            'Pass Assessment',
            'Fail Assessment'
        ]
    end

    let(:rows) do
        {
            module_name: [module_1, module_2],
            total_users: [0, 0],
            not_started: [0, 0],
            started: [0, 0],
            in_progress: [0, 0],
            completed: [0, 0],
            true_false: [0, 0],
            module_start: [0, 0],
            module_complete: [0, 0],

        }

    before do
        create(:module_item)
    end

    it_behaves_like('a data export model')
end