module DataAnalysis
  class ResitsPerUser
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'User ID',
          'Role',
          'Resit Attempts',
        ]
      end

      # @return [Array<Hash{Symbol => String,Integer}>]
      def dashboard
        resits.map do |(module_name, user_id), attempts|
          {
            module_name: module_name,
            user_id: user_id,
            role_type: user_roles[user_id],
            resit_attempts: attempts - 1,
          }
        end
      end

    private

      # @return [Hash{Integer => String}]
      def user_roles
        User.pluck(:id, :role_type).to_h
      end

      # @return [Hash{Array => Integer}]
      def assessments
        if Rails.application.migrated_answers?
          Assessment.order(:user_id).group(:training_module, :user_id).count
        else
          UserAssessment.summative.group(:module, :user_id).count
        end
      end

      # @return [Hash{Array => Integer}]
      def resits
        assessments.select { |_k, v| v > 1 }
      end
    end
  end
end
