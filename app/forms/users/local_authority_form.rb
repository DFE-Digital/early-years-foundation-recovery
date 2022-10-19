module Users
  class LocalAuthorityForm < BaseForm
    attr_accessor :local_authority

    def name
      'local_authorities'
    end

    def save
      user.update!(local_authority: local_authority)
    end
  end
end
