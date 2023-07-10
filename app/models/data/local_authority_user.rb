module Data
  class LocalAuthorityUser
    include ToCsv

    class << self
      # @return [String]
      def column_names
        ['Local Authority', 'Users']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        count_by_local_authority.map do |authority, count|
          {
            local_authority: authority,
            users: count,
          }
        end
      end

  private

      # @return [Hash{Symbol=>Integer}]
      def count_by_local_authority
        public_beta_users.group(:local_authority).count
      end

      # @return [ActiveRecord::Relation<User>]
      def public_beta_users
        User.since_public_beta.with_local_authority
      end
  end
  end
end
