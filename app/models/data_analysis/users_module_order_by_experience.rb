module DataAnalysis
  class UsersModuleOrderByExperience
    include ToCsv

    EXPERIENCE_BANDS = {
      'Less than 2 years' => 0..1,
      'Between 2 and 5 years' => 2..5,
      'Between 6 and 9 years' => 6..9,
      '10 years or more' => 10..Float::INFINITY,
    }.freeze

    MODULES = (1..8).map { |i| "Module #{i}" }.freeze

    REAL_MODULE_MAP = {
      'child-development-and-the-eyfs' => 'Module 1',
      'brain-development-and-how-children-learn' => 'Module 2',
      'personal-social-and-emotional-development' => 'Module 3',
      'module-4' => 'Module 4',
      'module-5' => 'Module 5',
      'module-6' => 'Module 6',
      'module-7' => 'Module 7',
      'module-8' => 'Module 8',
    }.freeze

    class << self
      def column_names
        %w[Experience ModuleName Module_Started_First Module_Started_Second Module_Started_Third]
      end

      def dashboard
        result = []

        EXPERIENCE_BANDS.each do |band_name, range|
          user_module_orders = {}

          users_in_band(range) do |users_batch|
            user_module_orders.merge!(build_user_module_orders(users_batch))
          end

          next if user_module_orders.empty?

          MODULES.each do |mod_name|
            counts = [0, 0, 0]

            user_module_orders.each_value do |modules_ordered|
              index = modules_ordered.index(mod_name)
              counts[index] += 1 if index && index < 3
            end

            result << {
              experience: band_name,
              module_name: mod_name,
              'Module Started First' => counts[0],
              'Module Started Second' => counts[1],
              'Module Started Third' => counts[2],
            }
          end
        end

        result
      end

      def to_csv
        rows = dashboard
        CSV.generate(headers: true) do |csv|
          csv << column_names
          rows.each do |row|
            csv << [
              row[:experience],
              row[:module_name],
              row['Module Started First'],
              row['Module Started Second'],
              row['Module Started Third'],
            ]
          end
        end
      end

    private

      # Yield users in batches filtered by experience band
      def users_in_band(range, batch_size: 1000, &block)
        User.not_closed
            .where.not(early_years_experience: nil)
            .where(early_years_experience: range)
            .select(:id, :early_years_experience)
            .find_in_batches(batch_size: batch_size, &block)
      end

      def build_user_module_orders(users)
        user_ids = users.map(&:id)
        events = Event.where(user_id: user_ids, name: 'module_start')
                      .order(:time)
                      .pluck(:user_id, :properties)

        orders = Hash.new { |h, k| h[k] = [] }

        events.each do |user_id, properties|
          next unless properties.is_a?(Hash)

          training_module_id = properties['training_module_id'] || properties['mod_uid']
          next unless training_module_id

          module_name = map_to_module_name(training_module_id)
          next unless module_name

          orders[user_id] << module_name unless orders[user_id].include?(module_name)
        end

        orders
      end

      def map_to_module_name(training_module_id)
        REAL_MODULE_MAP[training_module_id]
      end
    end
  end
end
