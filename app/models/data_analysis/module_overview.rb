module DataAnalysis
  class ModuleOverview
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
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

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        mods.map do |mod|
          {
            module_name: mod.name,
            total_users: User.not_closed.registration_complete.count,
            not_started: not_started(mod),
            started: started(mod),
            in_progress: in_progress(mod),
            completed: completed(mod),
            true_false: true_false_count(mod),
            module_start: Event.module_start.where_module(mod.name).count,
            module_complete: Event.module_complete.where_module(mod.name).count,
            confidence_check_start: Event.confidence_check_start.where_module(mod.name).count,
            confidence_check_complete: Event.confidence_check_complete.where_module(mod.name).count,
            start_assessment: Event.summative_assessment_start.where_module(mod.name).count,
            pass_assessment: Event.summative_assessment_pass(mod.name).count,
            fail_assessment: Event.summative_assessment_fail(mod.name).count,
          }
        end
      end

    private

      def mods
        Training::Module.ordered
      end

      def true_false_count(mod)
        mod.questions.count(&:true_false?)
      end

      def not_started(mod)
        User.not_closed.registration_complete.all.map { |u| u.module_time_to_completion[mod.name] }.count(&:nil?)
      end

      def in_progress(mod)
        User.not_closed.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:zero?)
      end

      def completed(mod)
        User.not_closed.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:positive?)
      end

      def started(mod)
        in_progress(mod) + completed(mod)
      end
    end
  end
end
