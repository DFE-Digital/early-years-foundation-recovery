module DataAnalysis
  class DeviceEngagement
    include ToCsv

    DEVICE_TYPES = %w[Desktop Mobile Tablet Other].freeze

    class << self
      def column_names
        [
          'Module Name',
          'Device Type',
          'Started Count',
          'Completed Count',
          'Completion Rate %',
          'Average Minutes',
          'Median Minutes',
          'P90 Minutes',
        ]
      end

      def dashboard
        rows = []
        Training::Module.ordered.reject(&:draft?).each do |mod|
          DEVICE_TYPES.each do |device|
            started_count = started_count_for(mod.name, device)
            durations = durations_for(mod.name, device)
            completed_count = durations.size
            completion_rate = completion_rate_percentage(started_count, completed_count)

            rows << {
              module_name: mod.name,
              device_type: device,
              started_count: started_count,
              completed_count: completed_count,
              completion_rate_percentage: completion_rate,
              average_minutes: average_minutes(durations),
              median_minutes: percentile_minutes(durations, 50),
              p90_minutes: percentile_minutes(durations, 90),
            }
          end
        end
        rows
      end

    private

      # Derive duration by device from ahoy events joined to visits.device_type
      def durations_for(module_name, device_type)
        # Join module_start and module_complete events by user/visit; rely on the first occurrence.
        starts = Event.where(name: 'module_start').where_properties(training_module_id: module_name)
                      .joins(:visit)
                      .yield_self { |rel| filter_device(rel, device_type) }
        completes = Event.where(name: 'module_complete').where_properties(training_module_id: module_name)
                         .joins(:visit)
                         .yield_self { |rel| filter_device(rel, device_type) }

        # Index by user and visit for pairing
        start_index = starts.group_by { |e| [e.user_id, e.visit_id] }.transform_values { |arr| arr.min_by(&:time) }
        complete_index = completes.group_by { |e| [e.user_id, e.visit_id] }.transform_values { |arr| arr.min_by(&:time) }

        durations = []
        start_index.each do |key, start_event|
          complete_event = complete_index[key]
          next unless complete_event && complete_event.time && start_event.time

          delta = (complete_event.time - start_event.time).to_i
          durations << delta if delta.positive?
        end
        durations
      end

      def started_count_for(module_name, device_type)
        starts = Event.where(name: 'module_start').where_properties(training_module_id: module_name)
                      .joins(:visit)
                      .yield_self { |rel| filter_device(rel, device_type) }

        # Count unique user/visit combinations
        starts.group_by { |e| [e.user_id, e.visit_id] }.size
      end

      def filter_device(relation, device_type)
        case device_type
        when 'Desktop' then relation.where(visits: { device_type: 'Desktop' })
        when 'Mobile'  then relation.where(visits: { device_type: 'Mobile' })
        when 'Tablet'  then relation.where(visits: { device_type: 'Tablet' })
        else relation.where.not(visits: { device_type: %w[Desktop Mobile Tablet] })
        end
      end

      def completion_rate_percentage(started_count, completed_count)
        return 0 if started_count.zero?

        (completed_count.to_f / started_count).round(4)
      end

      def average_minutes(durations_seconds)
        return 0 if durations_seconds.empty?

        (durations_seconds.sum.to_f / durations_seconds.size / 60).round(1)
      end

      def percentile_minutes(durations_seconds, percentile)
        return 0 if durations_seconds.empty?

        sorted = durations_seconds.sort
        rank = (percentile / 100.0) * (sorted.length - 1)
        lower = sorted[rank.floor]
        upper = sorted[rank.ceil]
        value = lower + (upper - lower) * (rank - rank.floor)
        (value / 60.0).round(1)
      end
    end
  end
end
