module DataAnalysis
  class ModuleDurationBuckets
    include ToCsv

    BUCKETS = [
      { label: '0-20 minutes',     range: 0..(20 * 60) },
      { label: '21-30 minutes',    range: (20 * 60 + 1)..(30 * 60) },
      { label: '31-45 minutes',    range: (30 * 60 + 1)..(45 * 60) },
      { label: '46-60 minutes',    range: (45 * 60 + 1)..(60 * 60) },
      { label: 'Over 60 minutes',  range: (60 * 60 + 1)..Float::INFINITY },
    ].freeze

    class << self
      def column_names
        [
          'Module Name',
          'Completed Count',
          'Average Minutes',
          'Median Minutes',
          'P90 Minutes',
          *BUCKETS.map { |b| b[:label] },
        ]
      end

      def dashboard
        Training::Module.ordered.reject(&:draft?).map do |mod|
          durations = completed_durations_seconds_for(mod.name)

          bucket_counts = bucketize(durations)

          {
            module_name: mod.name,
            completed_count: durations.size,
            average_minutes: average_minutes(durations),
            median_minutes: percentile_minutes(durations, 50),
            p90_minutes: percentile_minutes(durations, 90),
          }.merge(bucket_counts)
        end
      end

    private

      def completed_durations_seconds_for(module_name)
        # Pair module_start and module_complete events by user/visit to derive durations
        starts = Event.module_start.where_module(module_name)
        completes = Event.module_complete.where_module(module_name)

        # Index by [user_id, visit_id] using earliest occurrence
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

      def bucketize(durations_seconds)
        counts_by_label = BUCKETS.map { |b| [b[:label], 0] }.to_h
        durations_seconds.each do |sec|
          bucket = BUCKETS.find { |b| b[:range].include?(sec) }
          counts_by_label[bucket[:label]] += 1 if bucket
        end
        # Preserve column order by returning counts keyed to snake_case labels in BUCKETS order
        ordered = {}
        BUCKETS.each do |b|
          ordered[header_key(b[:label])] = counts_by_label[b[:label]]
        end
        ordered
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

      def header_key(label)
        label.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_+|_+$/, '').to_sym
      end
    end
  end
end
