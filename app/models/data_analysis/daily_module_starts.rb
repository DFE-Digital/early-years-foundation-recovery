module DataAnalysis
  class DailyModuleStarts
    include ToCsv

    WINDOW_DAYS = 60

    class << self
      # @return [Array<String>]
      def column_names
        ['Date', *module_names]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        counts = counts_by_date_and_module

        window_dates.map do |date|
          row = { date: date }
          module_names.each do |module_name|
            row[module_name] = counts.dig(date, module_name) || 0
          end
          row
        end
      end

    private

      # @return [ActiveSupport::TimeWithZone]
      def window_start
        WINDOW_DAYS.days.ago.beginning_of_day
      end

      # @return [ActiveSupport::TimeWithZone]
      def window_end
        1.day.ago.end_of_day
      end

      # @return [Array<String>]
      def module_names
        Training::Module.ordered.reject(&:draft?).map(&:name)
      end

      # @return [Array<Date>]
      def window_dates
        (window_start.to_date..window_end.to_date).to_a
      end

      # @return [Hash{Date => Hash{String => Integer}}]
      def counts_by_date_and_module
        UserModuleProgress.started
                          .where(started_at: window_start..window_end)
                          .group('DATE(started_at)', :module_name)
                          .count
                          .each_with_object({}) do |((date, module_name), count), grouped|
          grouped[date] ||= {}
          grouped[date][module_name] = count
        end
      end
    end
  end
end
