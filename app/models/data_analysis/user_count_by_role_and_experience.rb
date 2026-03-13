module DataAnalysis
  class UserCountByRoleAndExperience
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          Role
          Experience
          Count
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard(batch_size: 1000)
        return enum_for(:dashboard, batch_size: batch_size) unless block_given?

        role_and_experience_users.each do |(early_years_experience, role_type), count|
          yield({
            role_type: role_type,
            experience: early_years_experience,
            count: count,
          })
        end
      end

    private

      # @return [Hash{Symbol => Integer}]
      def role_and_experience_users
        all_users.group(:early_years_experience, :role_type).order(:early_years_experience, :role_type).count
      end

      # @return [User::ActiveRecord_Relation]
      def all_users
        User.not_closed.registration_complete_all_users
      end
    end
  end
end
