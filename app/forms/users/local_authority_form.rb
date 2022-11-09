module Users
  class LocalAuthorityForm < BaseForm
    attr_accessor :local_authority

    validates :local_authority, presence: true

    def name
      'local_authorities'
    end

    def save
      if valid?
        user.update!(
          local_authority: local_authority,
        )
      end
    end
  end
end
