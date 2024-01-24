module DataAnalysis
  class LocalAuthorityUser
    include ToCsv

    class << self
      # @return [String]
      def column_names
        [
          'Local Authority',
          'Users',
        ]
      end

      # @return [Array<Hash>]
      def dashboard
        authorities.map do |authority, count|
          {
            local_authority: authority,
            users: count,
          }
        end
      end

    private

      # @return [Hash{Symbol => Integer}]
      def authorities
        public_beta_users.group(:local_authority).order(:local_authority).count
      end

      # @return [User::ActiveRecord_Relation]
      def public_beta_users
        User.not_closed.with_local_authority.registration_complete
      end
    end
  end
end
