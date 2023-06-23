module Data
    class ModuleOverview
      include ToCsv
  
      def self.column_names
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
  
      def self.dashboard
        data = []
        mods.map do |mod|
            row = {
                module_name: mod.name,
                total_users: User.count,
                not_started: not_started(mod),
                started: started(mod),
                in_progress: in_progress(mod),
                completed: completed(mod),
                true_false: true_false_count(mod),
                module_start: Ahoy::Event.module_start.where_module(mod.name).count,
                module_complete: Ahoy::Event.module_complete.where_module(mod.name).count,
                confidence_check_start: Ahoy::Event.confidence_check_start.where_module(mod.name).count,
                confidence_check_complete: Ahoy::Event.confidence_check_complete.where_module(mod.name).count,
                start_assessment: Ahoy::Event.summative_assessment_start.where_module(mod.name).count,
                pass_assessment: Ahoy::Event.summative_assessment_pass(mod.name).count,
                fail_assessment: Ahoy::Event.summative_assessment_fail(mod.name).count
            }
            data << row
        end
        data
      end
  
      def self.mods
        if Rails.application.cms?
          Training::Module.ordered
        else
          TrainingModule.published
        end
      end
  
      def self.true_false_count(mod)
        return 'N/A' unless Rails.application.cms?
  
        mod.questions.count(&:true_false?)
      end
  
      def self.not_started(mod)
        User.all.map { |u| u.module_time_to_completion[mod.name] }.count(&:nil?)
      end
  
      def self.in_progress(mod)
        User.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:zero?)
      end
  
      def self.completed(mod)
        User.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:positive?)
      end
  
      def self.started(mod)
        in_progress(mod) + completed(mod)
      end
    end
  end
  