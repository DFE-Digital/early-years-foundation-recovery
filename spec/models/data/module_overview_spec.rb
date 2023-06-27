require 'rails_helper'

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
      'Fail Assessment',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        total_users: 0,
        not_started: 0,
        started: 0,
        in_progress: 0,
        completed: 0,
        true_false: 'N/A',
        module_start: 0,
        module_complete: 0,
        confidence_check_start: 0,
        confidence_check_complete: 0,
        start_assessment: 0,
        pass_assessment: 0,
        fail_assessment: 0,
      },
      {
        module_name: 'bravo',
        total_users: 0,
        not_started: 0,
        started: 0,
        in_progress: 0,
        completed: 0,
        true_false: 'N/A',
        module_start: 0,
        module_complete: 0,
        confidence_check_start: 0,
        confidence_check_complete: 0,
        start_assessment: 0,
        pass_assessment: 0,
        fail_assessment: 0,
      },
      {
        module_name: 'charlie',
        total_users: 0,
        not_started: 0,
        started: 0,
        in_progress: 0,
        completed: 0,
        true_false: 'N/A',
        module_start: 0,
        module_complete: 0,
        confidence_check_start: 0,
        confidence_check_complete: 0,
        start_assessment: 0,
        pass_assessment: 0,
        fail_assessment: 0,
      },
    ]
  end

  it_behaves_like('a data export model')
end
