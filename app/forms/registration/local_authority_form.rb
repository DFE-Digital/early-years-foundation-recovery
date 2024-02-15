module Registration
  class LocalAuthorityForm < BaseForm
    attr_accessor :local_authority

    validates :local_authority, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(local_authority: local_authority_clean)
    end

  private

    # @see Trainee:Authority#persisted_name
    # @return [String] remove old name suffix
    def local_authority_clean
      local_authority.gsub(/\(.*?\)/, '').strip
    end
  end
end
