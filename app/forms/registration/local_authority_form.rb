module Registration
  class LocalAuthorityForm < BaseForm
    attr_accessor :local_authority

    validates :local_authority, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(local_authority: local_authority)
    end
  end
end
